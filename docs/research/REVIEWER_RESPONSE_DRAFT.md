# Draft Response to asus-linux Reviewer

> Use this as a starting point for your response. Post it as a reply to their review.

---

Thank you for taking the time to look through the repo and for the detailed, constructive feedback. You're absolutely right on several fronts, and I appreciate the corrections from someone who knows this codebase far better than I do.

## 1. Bazzite / Terra Repos — You're Correct

The README framing was wrong. I didn't realize Bazzite already ships `asusctl` via Terra. The "strips out ASUS control layers" claim was based on my own experience installing a fresh Bazzite image and not finding ASUS tools pre-installed — but that's very different from saying they're unavailable. I've rewritten the README to accurately frame this project as a **model-specific tuning layer** rather than "installing asusctl on Bazzite."

The actual value here is:
- Factory-extracted fan curves (decoded from EC firmware)
- GU605MY-specific power limits and thermal tuning
- Custom keyboard effects (reactive/music/temp via direct HID)
- Slash LED support with custom animations
- Audio routing workarounds for ALC285 + CS35L56

I've also deprecated supergfxctl across the entire codebase based on your feedback.

## 2. supergfxctl Deprecation

I wasn't aware supergfxctl was deprecated. I've now:
- Marked it deprecated in all scripts, docs, and install guides
- Added warnings that disabling dGPU via supergfxctl often leaves it powered-on but inaccessible
- Directed users toward NVIDIA driver's native power management instead

I'd love to test Luytan's replacement when it's ready. Is there a repo or branch I can follow?

## 3. Audio Kernel Upstreaming

The ALC285 + CS35L56 routing fixes are the biggest pain point. The internal speakers work but PipeWire's ALSA bridge behaves differently than Windows' WASAPI path. I'd appreciate guidance on:
- Which kernel bug tracker to use (bugzilla.kernel.org?)
- What specific information you need from the GU605MY to make the report useful
- Whether the CS35L56 firmware loading issue is a `snd-hda-intel` problem or a firmware packaging issue

## 4. CPU Governor — Model-Specific

You're right, and I should have been clearer about this. The `performance` governor + Intel P-State combination is what reaches max clocks on the GU605MY with the Core Ultra 9 185H. I've added a model-specific note to the tuning guide warning users not to blindly copy this to AMD hardware where `powersave` + amd-epp is the correct path.

## 5. Fn-Key Scancodes → Kernel

The `90-asus-fnkeys` udev hwdb rules in this repo were a stopgap. I'd absolutely like to get the actual scancodes into the kernel `hid-asus` driver where they belong. What's the best way to collaborate on this? Should I open an issue on the asus-linux tracker with the discovered values, or go straight to linux-input@vger.kernel.org?

## 6. Slash LED Fork — 6.3.4 Base

Yes, the fork is based on **asusctl 6.3.4** (commit `d2006046`). At that time, I branched off to add:
- Slash LED tab to rog-control-center (16 modes, brightness, interval, show-on-lid-closed)
- Custom `.slashlighting` animation playback via external player
- Keyboard brightness and display brightness controls
- GU605MY-specific branding and error handling

I haven't rebased onto current devel because I wasn't sure how much the Slash management had diverged after supergfxctl was removed. **Commit 5ff4d120** fixed a deadlock in `reload()` where `lock_config()` was held while re-acquiring, plus a D-Bus type mismatch where `set_mode` accepted `SlashMode` but the proxy sent `u8`. I found these independently on 6.3.4 — did you fix the same bugs in devel?

What's the best way to bring the GU605MY Slash features forward? Should I:
- Rebase the entire fork onto current devel?
- Open individual PRs for each feature?
- Or is Slash support for GU605MY already in progress upstream?

## 7. Sound Work / Microphone Calibration

I'd absolutely love that resource on microphone calibration via PipeWire. The Focusrite Scarlett 18i8 routing in this repo is held together with duct tape and `module-remap-source`. A proper calibration/linearization pipeline would be a huge improvement.

---

Thanks again for the thorough review. This project exists because your upstream work made it possible — the goal was never to replace asus-linux, but to fill in the model-specific gaps for the GU605MY. I'm happy to upstream whatever is useful and collaborate where it makes sense.

Let me know how you'd like to proceed on the kernel bug reports, fn-key scancodes, and rebasing.
