;;; hl-sentence.el --- Highlight a sentence based on customizable face

;; Copyright (c) 2011 Donald Ephraim Curtis

;; This file is not part of GNU Emacs.

;;; License:

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License
;; as published by the Free Software Foundation; either version 3
;; of the License, or (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:
;;
;; Highlight the current sentence using `hl-sentence' face.
;;
;; To use this package, add the following code to your `emacs-init-file'
;;
;; (require 'hl-sentence)
;; (add-hook 'YOUR-MODE-HOOK 'hl-sentence-mode)
;;
;; You can customize the face to make it look the way you like
;;
;; (set-face-attribute 'hl-sentence nil
;;                     :foreground "#444")
;;
;; Please send bug reports to
;; https://github.com/milkypostman/hl-sentence/issues
;;
;; This mode started out as a bit of elisp at
;; http://www.emacswiki.org/emacs/SentenceHighlight by Aaron Hawley.
;;; Code:
(require 'org-element)
(require 'subr-x)  ; Compatibility

(defgroup hl-sentence nil
  "Highlight the current sentence."
  :group 'convenience)

;;;###autoload
(defface hl-sentence '((t :inherit nil
                        :background nil
                        :foreground "wheat3"))
  "The face used to highlight the current sentence."
  :group 'hl-sentence)

(defun hl-sentence-begin-pos ()
  "Return the point of the beginning of a sentence."
  (save-excursion
    (unless (= (point) (point-max))
      (forward-char))
    (backward-sentence)
    (point)))

(defun hl-sentence-end-pos ()
  "Return the point of the end of a sentence."
  (save-excursion
    (unless (= (point) (point-max))
      (forward-char))
    (backward-sentence)
    (forward-sentence)
    (point)))

(defvar hl-sentence-extent nil
  "The location of the hl-sentence-mode overlay.")

;;;###autoload
(define-minor-mode hl-sentence-mode
  "Enable highlighting of currentent sentence."
  :init-value nil
  (if hl-sentence-mode
      (add-hook 'post-command-hook 'hl-sentence-current nil t)
    (move-overlay hl-sentence-extent 0 0 (current-buffer))
    (remove-hook 'post-command-hook 'hl-sentence-current t)))

(defun plainp ()
  "Check current sentence is paragraph and it's parent is section."
  (and
   (eq (org-element-type (org-element-at-point)) 'paragraph)
   (or
    (eq (org-element-type (org-element-property :parent (org-element-at-point))) 'section)
    (eq (org-element-type (org-element-property :parent (org-element-at-point))) 'item)
    )))

(defun hl-sentence-current ()
  "Highlight current sentence."
  (and hl-sentence-mode
       (plainp)
       (> (buffer-size) 0)
       (boundp 'hl-sentence-extent)
       hl-sentence-extent
       (move-overlay hl-sentence-extent
                     (hl-sentence-begin-pos)
                     (hl-sentence-end-pos)
                     (current-buffer))))

(setq hl-sentence-extent (make-overlay 0 0))
(overlay-put hl-sentence-extent 'face 'hl-sentence)

(add-hook 'org-mode 'hl-sentence-mode)

(provide 'hl-sentence)
;;; hl-sentence.el ends here
