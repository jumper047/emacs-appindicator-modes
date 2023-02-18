;;; appindicator-pomm.el --- Tray icon for pomm-mode  -*- lexical-binding:t -*-

;; Copyright (c) 2022 by Dmitriy Pshonko.

;; Author: Dmitriy Pshonko <jumper047@gmail.com>
;; URL: https://github.com/jumper047/emacs-appindicator-modes
;; Keywords: mouse convenience
;; Version: 0.1.0

;; Package-Requires: ((emacs "26.1") (appindicator "0.1.0"))

;; This file is NOT part of GNU Emacs

;;; License:

;; This program is free software: you can redistribute it and/or modify
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

;; To enable tray icon add to your config:
;; (require 'appindicator-pomm)
;; (appindicator-pomm-mode +1)

;;; Code:

(require 'appindicator)

(defvar appindicator-pomm-icon
  (concat (file-name-directory (locate-library "appindicator-pomm.el"))
          "egg-timer.svg")
  "Path to the pomm tray icon.")

(defun appindicator-pomm-update-menu ()
  "Update appindicator context menu according to pomm state."
  (let* ((status (alist-get 'status pomm--state))
         (current (alist-get 'current pomm--state))
         (menu '(separator
                 ("Reset" . pomm-reset)
                 ("Hide tray icon" . (lambda () (appindicator-pomm-mode -1))))))
    (cond ((eq status 'stopped)
           (push '("Start" . pomm-start) menu))
          ((eq status 'paused)
           (push '("Stop" . pomm-stop) menu)
           (push '("Start" . pomm-start) menu))
          ((eq status 'running)
           (push '("Stop" . pomm-stop) menu)
           (push '("Pause" . pomm-pause) menu)))
    (appindicator-pomm-set-menu menu)))

(defun appindicator-pomm-update-label ()
  (appindicator-pomm-set-label (pomm-format-mode-line)))

(define-minor-mode appindicator-pomm-mode
  "Display current pomm state in system tray"
  :group 'appindicator-pomm
  :global t
  (if appindicator-pomm-mode
      (progn
        (appindicator-create "pomm")
        (appindicator-pomm-set-icon appindicator-pomm-icon)
        (appindicator-pomm-set-active t)
        (add-hook 'pomm-on-tick-hook #'appindicator-pomm-update-label)
        (add-hook 'pomm-on-status-changed-hook #'appindicator-pomm-update-menu)
        (add-hook 'pomm-on-status-changed-hook #'appindicator-pomm-update-label)
        (appindicator-pomm-update-label)
        (appindicator-pomm-update-menu))
    (remove-hook 'pomm-on-tick-hook #'appindicator-pomm-update-label)
    (remove-hook 'pomm-on-status-changed-hook #'appindicator-pomm-update-menu)
    (remove-hook 'pomm-on-status-changed-hook #'appindicator-pomm-update-label)
    (appindicator-pomm-kill)))

(provide 'appindicator-pomm)
;;; appindicator-pomm.el ends here
