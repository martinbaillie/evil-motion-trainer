;;; evil-motion-trainer.el --- Trains you to use better evil motions.

;; Copyright (C) 2020 Martin Baillie

;; Author: Martin Baillie <martin@baillie.email>
;; Keywords: learning
;; Version: 0.01
;; Package-Requires: ((cl-lib "0.5"))

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Entering `evil-motion-trainer-mode' makes Emacs drop lazily repeated
;; "hjkl"-based motions after a configurable threshold, forcing you to think
;; about a more precise motion.

;;; Code:
(require 'cl-lib)

(defvar evil-motion-trainer-mode nil
  "Trains you to use better evil motions.")

(defvar evil-motion-trainer-threshold 8
  "Number of permitted repeated key presses.")

(defvar evil-motion-trainer-super-annoying-mode nil
  "Switches to and shows an annoying message in another buffer.")

(defvar evil-motion-trainer--current-count 2
  "Defaults to two because first two keypresses are registered as one.")

;; Since evil-commands sometimes call themselves recursively (evil-forward-char
;; calls itself 2-3 times, for example) we need to ensure that the user actually
;; pressed the keys for those commands several times. We do this by ensuring
;; that the time between command calls is longer than some threshold. Without
;; this check, 3-4 calls of evil-forward char would be enough to trigger the
;; bell with a too far count of 10.

(defvar emt--old-time (float-time))
(defvar emt--old-temp nil)
(defun emt--check-enough-time-passed (new-time)
  (progn
    (setq emt--old-temp emt--old-time)
    (setq emt--old-time new-time)
    (< 0.01 (- emt--old-time emt--old-temp))))

(defvar emt--commands nil)
(defun emt--commands-with-shortcuts (cmds)
  (cl-remove-if (lambda (cmd)
                  (and
                   (>= (length (substitute-command-keys (format "\\[%S]" cmd))) 3)
                   (string-equal
                    (substring (substitute-command-keys (format "\\[%S]" cmd)) 0 3)
                    "M-x"))) cmds))

(defun emt--maybe-block (orig-fn &rest args)
  (let ((cmd this-command))
    (when (and evil-motion-trainer-mode
               (emt--check-enough-time-passed (float-time)))
      (if (and (memq this-command emt--commands)
               (or (eq this-command last-command)
                   (eq (get cmd 'alternative-cmd) last-command)))
          (progn
            (cl-incf evil-motion-trainer--current-count)
            (when (> evil-motion-trainer--current-count evil-motion-trainer-threshold)
              (let* ((alts (emt--commands-with-shortcuts (get cmd 'emt--alts)))
                     (alt (nth (random (length alts)) alts))
                     (key (substitute-command-keys (format "\\[%S]" alt)))
                     (msg (format "Lazy motion! How about using %S (keymap: %s) instead?" alt key)))
                (if evil-motion-trainer-super-annoying-mode
                    (progn (switch-to-buffer (get-buffer-create "Evil motion trainer"))
                           (insert msg))
                  (user-error msg)))))
        (setq evil-motion-trainer--current-count 2)))
    (apply orig-fn args)))

(defmacro add-emt-advice (cmd alternatives &optional helper-cmd)
  `(progn
     (add-to-list 'emt--commands (quote ,cmd))
     (put (quote ,cmd) 'emt--alts ,alternatives)
     (put (quote ,cmd) 'alternative-cmd (quote ,helper-cmd))
     (put (quote ,helper-cmd) 'alternative-cmd (quote ,cmd))
     (advice-add (quote ,cmd) :around #'emt--maybe-block)))

(add-emt-advice evil-next-line '(evil-search-forward evil-jumper/backward evil-snipe-s) next-line)
(add-emt-advice evil-previous-line '(evil-search-backward evil-snipe-S evil-jumper/backward evil-find-char-backward) previous-line)
(add-emt-advice evil-forward-char '(evil-search-forward evil-find-char evil-snipe-f evil-snipe-s))
(add-emt-advice evil-backward-char '(evil-search-backward evil-find-char-backward evil-snipe-F evil-snipe-S))

;;;###autoload
(define-minor-mode evil-motion-trainer-mode "Evil motion trainer minor mode.")

;;;###autoload
(define-globalized-minor-mode global-evil-motion-trainer-mode
  evil-motion-trainer-mode evil-motion-trainer-mode)

(defun emt-add-suggestion (cmd alternative)
  (let ((old-alts (or (get cmd 'emt--alts)
                      ())))
    (unless (memq alternative old-alts)
      (put cmd 'emt--alts (cons alternative old-alts)))))

(defun emt-add-suggestions (cmd alternatives)
  (let ((old-alts (or (get cmd 'emt--alts)
                      ())))
    (put cmd 'emt--alts (append
                         (remove-if (lambda (cmd)
                                      (memq cmd old-alts)) alternatives)
                         old-alts))))

(provide 'evil-motion-trainer)
;;; evil-motion-trainer.el ends here
