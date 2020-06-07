# evil-motion-trainer

## About

You've already opted to give your Emacs setup a streak of [modal
editing](https://github.com/emacs-evil/evil)
[malevolence](https://github.com/PythonNut/evil-easymotion), so why not train
yourself to move around your Emacs evil buffer with all the grace and poise of
advanced motions. We are not barbarians, after all.

Entering `evil-motion-trainer-mode` makes Emacs drop lazily repeated
<kbd>h</kbd><kbd>j</kbd><kbd>k</kbd><kbd>l</kbd>-based motions after a
configurable threshold, forcing you to think about a more precise motion.

### Why?

Simply put, these keys are not the best choice for the job in most cases.
Word-wise motions (e.g. <kbd>w</kbd><kbd>W</kbd>, <kbd>b</kbd><kbd>B</kbd>,
<kbd>e</kbd><kbd>E</kbd>, <kbd>ge</kbd>), character searches (e.g.
<kbd>f</kbd><kbd>F</kbd>, <kbd>t</kbd><kbd>T</kbd>, <kbd>,</kbd>, <kbd>;</kbd>)
and line jumps (e.g. <kbd>10j</kbd> <kbd>5k</kbd>) will get you there with less
keystrokes.

## Configuration

Enable in a buffer with:

```emacs-lisp
(evil-motion-trainer-mode)
```

Turn on for all buffers:

```emacs-lisp
(global-evil-motion-trainer-mode 1)
```

Configure the number of permitted repeated key presses:

```emacs-lisp
(setq evil-motion-trainer-threshold 6)
```

Enable a super annoying mode that pops a warning in a buffer:

```emacs-lisp
(setq evil-motion-trainer-super-annoying-mode t)
```

Add to the suggested alternatives for a key:

```emacs-lisp
(emt-add-suggestion 'evil-next-line 'evil-avy-goto-char-timer)
;; See also: (emt-add-suggestions)
```

## References

This package borrows from and was inspired by:

- Emacs annoying-arrows-mode
- Emacs evil-annoying-arrows-mode
- Vim hardtime
- Vim hardmode
