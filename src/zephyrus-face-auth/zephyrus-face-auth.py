#!/usr/bin/env python3
"""
Zephyrus Face Auth - KDE-native GUI for Howdy
PyQt6-based management app for face authentication
"""

import sys
import subprocess
import os
import cv2
import numpy as np
from pathlib import Path

from PyQt6.QtWidgets import (
    QApplication, QMainWindow, QWidget, QVBoxLayout, QHBoxLayout,
    QLabel, QPushButton, QComboBox, QSpinBox, QDoubleSpinBox,
    QGroupBox, QMessageBox, QTextEdit, QProgressBar, QFrame,
    QSlider, QCheckBox, QLineEdit, QFileDialog
)
from PyQt6.QtCore import Qt, QTimer, QThread, pyqtSignal, QRunnable, QThreadPool, QObject
from PyQt6.QtGui import QImage, QPixmap, QFont, QIcon


class CameraThread(QThread):
    frame_ready = pyqtSignal(np.ndarray)
    error = pyqtSignal(str)

    def __init__(self, device_path="/dev/video2"):
        super().__init__()
        self.device_path = device_path
        self.running = True
        self.cap = None

    def run(self):
        self.cap = cv2.VideoCapture(self.device_path)
        if not self.cap.isOpened():
            self.error.emit(f"Cannot open camera: {self.device_path}")
            return
        while self.running:
            ret, frame = self.cap.read()
            if ret:
                self.frame_ready.emit(frame)
            else:
                self.error.emit("Camera read failed")
                break
        if self.cap:
            self.cap.release()

    def stop(self):
        self.running = False
        self.wait(1000)


class HowdyWorker(QRunnable):
    class Signals(QObject):
        finished = pyqtSignal(str, int)

    def __init__(self, command):
        super().__init__()
        self.command = command
        self.signals = self.Signals()

    def run(self):
        try:
            result = subprocess.run(
                self.command, shell=True, capture_output=True, text=True, timeout=30
            )
            output = result.stdout + result.stderr
            self.signals.finished.emit(output, result.returncode)
        except subprocess.TimeoutExpired:
            self.signals.finished.emit("Command timed out", 1)
        except Exception as e:
            self.signals.finished.emit(str(e), 1)


class ZephyrusFaceAuth(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Zephyrus Face Auth")
        self.setMinimumSize(640, 480)
        self.camera_thread = None
        self.thread_pool = QThreadPool()

        self._build_ui()
        self._refresh_status()

    def _build_ui(self):
        central = QWidget()
        self.setCentralWidget(central)
        layout = QVBoxLayout(central)
        layout.setSpacing(12)
        layout.setContentsMargins(16, 16, 16, 16)

        # Title
        title = QLabel("🔐 Zephyrus Face Auth")
        title_font = QFont()
        title_font.setPointSize(18)
        title_font.setBold(True)
        title.setFont(title_font)
        title.setAlignment(Qt.AlignmentFlag.AlignCenter)
        layout.addWidget(title)

        subtitle = QLabel("Howdy Face Authentication Manager")
        subtitle.setAlignment(Qt.AlignmentFlag.AlignCenter)
        layout.addWidget(subtitle)

        layout.addSpacing(8)

        # Status group
        status_group = QGroupBox("Status")
        status_layout = QVBoxLayout(status_group)

        self.status_label = QLabel("Checking...")
        self.status_label.setStyleSheet("font-size: 14px; font-weight: bold;")
        status_layout.addWidget(self.status_label)

        self.model_count_label = QLabel("")
        status_layout.addWidget(self.model_count_label)

        status_btn_layout = QHBoxLayout()
        self.enable_btn = QPushButton("Enable")
        self.enable_btn.clicked.connect(self._enable_howdy)
        self.disable_btn = QPushButton("Disable")
        self.disable_btn.clicked.connect(self._disable_howdy)
        self.test_btn = QPushButton("🧪 Test Recognition")
        self.test_btn.setStyleSheet("background-color: #2196F3; color: white; font-weight: bold;")
        self.test_btn.clicked.connect(self._test_howdy)
        status_btn_layout.addWidget(self.enable_btn)
        status_btn_layout.addWidget(self.disable_btn)
        status_btn_layout.addStretch()
        status_btn_layout.addWidget(self.test_btn)
        status_layout.addLayout(status_btn_layout)

        layout.addWidget(status_group)

        # Camera preview group
        cam_group = QGroupBox("Camera Preview")
        cam_layout = QVBoxLayout(cam_group)

        self.cam_label = QLabel("Camera off")
        self.cam_label.setMinimumHeight(240)
        self.cam_label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        self.cam_label.setStyleSheet("background-color: #1a1a1a; color: #888; border-radius: 8px;")
        cam_layout.addWidget(self.cam_label)

        cam_btn_layout = QHBoxLayout()
        self.preview_btn = QPushButton("▶️ Start Preview")
        self.preview_btn.clicked.connect(self._toggle_preview)
        self.add_model_btn = QPushButton("➕ Add Face Model")
        self.add_model_btn.setStyleSheet("background-color: #4CAF50; color: white; font-weight: bold;")
        self.add_model_btn.clicked.connect(self._add_model)
        self.remove_model_btn = QPushButton("🗑️ Remove Model")
        self.remove_model_btn.clicked.connect(self._remove_model)
        cam_btn_layout.addWidget(self.preview_btn)
        cam_btn_layout.addWidget(self.add_model_btn)
        cam_btn_layout.addWidget(self.remove_model_btn)
        cam_layout.addLayout(cam_btn_layout)

        layout.addWidget(cam_group)

        # Settings group
        settings_group = QGroupBox("Settings")
        settings_layout = QVBoxLayout(settings_group)

        cam_row = QHBoxLayout()
        cam_row.addWidget(QLabel("Camera Device:"))
        self.cam_combo = QComboBox()
        self.cam_combo.addItem("IR Camera (/dev/video2)", "/dev/video2")
        self.cam_combo.addItem("RGB Camera (/dev/video0)", "/dev/video0")
        cam_row.addWidget(self.cam_combo, 1)
        self.apply_cam_btn = QPushButton("Apply")
        self.apply_cam_btn.clicked.connect(self._apply_camera)
        cam_row.addWidget(self.apply_cam_btn)
        settings_layout.addLayout(cam_row)

        thresh_row = QHBoxLayout()
        thresh_row.addWidget(QLabel("Certainty Threshold:"))
        self.thresh_spin = QDoubleSpinBox()
        self.thresh_spin.setRange(1.0, 10.0)
        self.thresh_spin.setSingleStep(0.5)
        self.thresh_spin.setValue(3.5)
        self.thresh_spin.setDecimals(1)
        thresh_row.addWidget(self.thresh_spin)
        thresh_row.addStretch()
        settings_layout.addLayout(thresh_row)

        timeout_row = QHBoxLayout()
        timeout_row.addWidget(QLabel("Timeout (seconds):"))
        self.timeout_spin = QSpinBox()
        self.timeout_spin.setRange(1, 30)
        self.timeout_spin.setValue(4)
        timeout_row.addWidget(self.timeout_spin)
        timeout_row.addStretch()
        settings_layout.addLayout(timeout_row)

        self.apply_settings_btn = QPushButton("💾 Save Settings")
        self.apply_settings_btn.clicked.connect(self._save_settings)
        settings_layout.addWidget(self.apply_settings_btn)

        layout.addWidget(settings_group)

        # Output log
        self.log_text = QTextEdit()
        self.log_text.setReadOnly(True)
        self.log_text.setMaximumHeight(120)
        self.log_text.setPlaceholderText("Output log...")
        layout.addWidget(self.log_text)

        # Bottom buttons
        bottom_layout = QHBoxLayout()
        self.clear_log_btn = QPushButton("Clear Log")
        self.clear_log_btn.clicked.connect(self.log_text.clear)
        bottom_layout.addWidget(self.clear_log_btn)
        bottom_layout.addStretch()
        self.close_btn = QPushButton("Close")
        self.close_btn.clicked.connect(self.close)
        bottom_layout.addWidget(self.close_btn)
        layout.addLayout(bottom_layout)

    def _log(self, text):
        self.log_text.append(text)

    def _run_howdy(self, args, callback=None):
        cmd = f"/usr/local/bin/howdy {args}"
        self._log(f"> {cmd}")
        worker = HowdyWorker(cmd)
        worker.signals.finished.connect(
            lambda out, rc: self._handle_result(out, rc, callback)
        )
        self.thread_pool.start(worker)

    def _handle_result(self, output, returncode, callback=None):
        self._log(output)
        if callback:
            callback(output, returncode)

    def _refresh_status(self):
        def on_status(output, rc):
            if "disabled" in output.lower():
                self.status_label.setText("❌ Disabled")
                self.status_label.setStyleSheet("font-size: 14px; font-weight: bold; color: #f44336;")
            else:
                self.status_label.setText("✅ Enabled")
                self.status_label.setStyleSheet("font-size: 14px; font-weight: bold; color: #4CAF50;")
            self._run_howdy("list", on_list)

        def on_list(output, rc):
            lines = [l for l in output.splitlines() if l.strip()]
            count = len(lines)
            self.model_count_label.setText(f"Face models: {count}")

        self._run_howdy("status", on_status)

    def _enable_howdy(self):
        self._run_howdy("disable clear", self._refresh_status)
        self._log("Howdy enabled")
        QTimer.singleShot(500, self._refresh_status)

    def _disable_howdy(self):
        self._run_howdy("disable add solarious", self._refresh_status)
        self._log("Howdy disabled")
        QTimer.singleShot(500, self._refresh_status)

    def _test_howdy(self):
        QMessageBox.information(self, "Test", "Look at the camera. Running test...")
        self._run_howdy("test", lambda out, rc: QMessageBox.information(self, "Test Result", out[:500]))

    def _toggle_preview(self):
        if self.camera_thread and self.camera_thread.isRunning():
            self._stop_camera()
            self.preview_btn.setText("▶️ Start Preview")
        else:
            device = self.cam_combo.currentData()
            self._start_camera(device)
            self.preview_btn.setText("⏹️ Stop Preview")

    def _start_camera(self, device_path="/dev/video2"):
        self._stop_camera()
        self.camera_thread = CameraThread(device_path)
        self.camera_thread.frame_ready.connect(self._update_frame)
        self.camera_thread.error.connect(self._log)
        self.camera_thread.start()

    def _stop_camera(self):
        if self.camera_thread:
            self.camera_thread.stop()
            self.camera_thread = None
        self.cam_label.setText("Camera off")

    def _update_frame(self, frame):
        rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        h, w, ch = rgb.shape
        bytes_per_line = ch * w
        qt_image = QImage(rgb.data, w, h, bytes_per_line, QImage.Format.Format_RGB888)
        pixmap = QPixmap.fromImage(qt_image)
        scaled = pixmap.scaled(
            self.cam_label.size(),
            Qt.AspectRatioMode.KeepAspectRatio,
            Qt.TransformationMode.SmoothTransformation
        )
        self.cam_label.setPixmap(scaled)

    def _add_model(self):
        device = self.cam_combo.currentData()
        self._start_camera(device)
        self.preview_btn.setText("⏹️ Stop Preview")
        reply = QMessageBox.question(
            self, "Add Face Model",
            "Look straight at the camera and click OK to capture your face.",
            QMessageBox.StandardButton.Ok | QMessageBox.StandardButton.Cancel
        )
        if reply == QMessageBox.StandardButton.Ok:
            self._run_howdy("add", lambda out, rc: (self._refresh_status(), QMessageBox.information(self, "Result", out[:500])))
        self._stop_camera()
        self.preview_btn.setText("▶️ Start Preview")

    def _remove_model(self):
        reply = QMessageBox.warning(
            self, "Remove Model",
            "Remove your face model?",
            QMessageBox.StandardButton.Yes | QMessageBox.StandardButton.No
        )
        if reply == QMessageBox.StandardButton.Yes:
            self._run_howdy("remove solarious", self._refresh_status)
            QTimer.singleShot(500, self._refresh_status)

    def _apply_camera(self):
        device = self.cam_combo.currentData()
        pkexec_cmd = f"pkexec sed -i 's|device_path = .*|device_path = {device}|' /usr/local/etc/howdy/config.ini"
        self._log(f"> {pkexec_cmd}")
        result = subprocess.run(pkexec_cmd, shell=True, capture_output=True, text=True)
        self._log(result.stdout + result.stderr)
        QMessageBox.information(self, "Camera", f"Camera set to {device}")

    def _save_settings(self):
        thresh = self.thresh_spin.value()
        timeout = self.timeout_spin.value()
        pkexec_cmd = (
            f"pkexec bash -c '"
            f"sed -i \"s/certainty = .*/certainty = {thresh}/\" /usr/local/etc/howdy/config.ini; "
            f"sed -i \"s/timeout = .*/timeout = {timeout}/\" /usr/local/etc/howdy/config.ini"
            f"'"
        )
        self._log(f"> {pkexec_cmd}")
        result = subprocess.run(pkexec_cmd, shell=True, capture_output=True, text=True)
        self._log(result.stdout + result.stderr)
        QMessageBox.information(self, "Settings", "Settings saved!")

    def closeEvent(self, event):
        self._stop_camera()
        event.accept()


def main():
    app = QApplication(sys.argv)
    app.setStyle("Fusion")
    
    # Dark palette for KDE
    palette = app.palette()
    palette.setColor(palette.ColorRole.Window, Qt.GlobalColor.darkGray)
    palette.setColor(palette.ColorRole.WindowText, Qt.GlobalColor.white)
    app.setPalette(palette)

    window = ZephyrusFaceAuth()
    window.show()
    sys.exit(app.exec())


if __name__ == "__main__":
    main()
