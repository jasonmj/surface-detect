;;; surface-detect.el --- Automatically switch between Elixir and Web modes

;; This file is not part of Emacs

;; Copyright (C) 2021 by Jason Johnson
;; Package-Requires: ((elixir-mode "20210509.2353") (web-mode "20210131.1758"))
;; Author:          Jason Johnson (jason@fullsteamlabs.com)
;; Maintainer:      Jason Johnson (jason@fullsteamlabs.com)
;; Created:         August 11, 2021
;; Keywords:        code, elixir
;; URL: https://github.com/jasonmj/surface-detect
;; Version: 0.0.1

;; COPYRIGHT NOTICE

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; version 3.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Commentary:

;;  Simple package to switch between elixir-mode and web-mode when viewing .ex
;;  files. Checks the current cursor position on an interval to determine if
;;  inside a code block that starts with the ~F sigil.
;;  This is a global minor mode.

;;; Usage:

;;  M-x `surface-detect-mode'
;;      Toggles surface-detect-mode on & off.  Optional arg turns
;;      surface-detect-mode on if arg is a positive integer.

;;; Comments:

;;  Any comments, suggestions, bug reports or upgrade requests are
;;  welcome.  Please create issues or send pull requests via Github at
;;  https://github.com/jasonmj/surface-detect.

;;; Change Log:

;;  See https://github.com/jasonmj/surface-detect/commits/main

;;; Code:

;;; **************************************************************************
;;; ***** require
;;; **************************************************************************

(require 'elixir-mode)
(require 'web-mode)

;;; **************************************************************************
;;; ***** define group
;;; **************************************************************************

(defgroup surface-detect nil
  "Automatically switches major modes between elixir-mode and web-mode"
  :prefix "surface-detect-")

;;; **************************************************************************
;;; ***** define customization options
;;; **************************************************************************

(defcustom surface-detect-switched nil
  "Hooks run when surface-detect changes major modes."
  :type 'hook
  :group 'surface-detect)

(defcustom surface-detect-timer-interval 0.3
  "The interval at which the cursor position should be checked."
  :type 'integer
  :group 'surface-detect)

(defvar surface-detect-timer nil
  "A variable for keeping track of the surface detect timer.")

;;; **************************************************************************
;;; ***** utility functions
;;; **************************************************************************

(defun surface-detect()
  (setq originalPos (line-number-at-pos))
  (beginning-of-buffer)
  (if (search-forward "~F\"\"\"" nil t)
      (progn
        (setq firstLine
              (buffer-substring-no-properties
               (line-beginning-position)
               (line-end-position)))
        (search-forward "~F\"\"\"" nil t)
        (setq sigilPos (line-number-at-pos))
        (search-forward "\"\"\"" nil t)
        (setq endQuotesPos (line-number-at-pos))
        (setq endQuotesLine (thing-at-point 'line))
        (pop-to-mark-command)
        (if (>= originalPos endQuotesPos)
            (unless (eq major-mode 'elixir-mode)
              (progn
                (elixir-mode)
                (run-hooks 'surface-detect-switched)))
          (if (>= originalPos sigilPos)
              (unless (eq major-mode 'web-mode)
                (progn
                  (web-mode)
                  (run-hooks 'surface-detect-switched)))
            (if (< originalPos sigilPos)
                (unless (eq major-mode 'elixir-mode)
                  (progn
                    (elixir-mode)
                    (run-hooks 'surface-detect-switched)))))))
    (pop-to-mark-command)))

(defun surface-detect-disable ()
  "Cancels the timer and ensures surface-detect-mode is off."
  (cancel-timer surface-detect-timer)
  (setq surface-detect-timer nil)
  (setq surface-detect-mode nil))

(defun surface-detect-check ()
  "Runs surface-detect if the file extension is .ex"
  (if 'surface-detect-mode
      (progn (if (string-match-p (regexp-quote ".ex") (buffer-name))
                 (surface-detect))
             (surface-detect-watch))
    (surface-detect-disable)))

(defun surface-detect-watch ()
  "Start the 'surface-detect-timer'."
  (setq surface-detect-timer
            (run-with-timer surface-detect-timer-interval nil 'surface-detect-check)))

;;; **************************************************************************
;;; ***** mode definition
;;; **************************************************************************

;;;###autoload
(define-minor-mode surface-detect-mode
  "Toggle use of 'surface-detect-mode'.
This minor automatically switches between elixir-mode and web-mode when
working with buffers that include the ~F sigil."
  :lighter " enabled"
  :init-value nil
  :keymap nil
  :global t
  :group 'surface-detect

  (if surface-detect-mode
      (surface-detect-watch)
    (surface-detect-disable)))

(provide 'surface-detect)

;;; surface-detect.el ends here
