;;; hl-tags-mode --- Highlight the current SGML tag context

;; Copyright (c) 2011 Mike Spindel <deactivated@gmail.com>

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

;; hl-tags-mode is a minor mode for SGML editing that highlights the
;; current start and end tag.
;;
;; To use hl-tags-mode, add the following to your .emacs:
;;
;;   (require 'hl-tags-mode)
;;   (add-hook 'sgml-mode-hook (lambda () (hl-tags-mode 1)))
          

;;; Code:

(defvar hl-tags-start-overlay nil)
(make-variable-buffer-local 'hl-tags-start-overlay)

(defvar hl-tags-end-overlay nil)
(make-variable-buffer-local 'hl-tags-end-overlay)

(defun hl-tags-context ()
  (save-excursion
    (let ((ctx (sgml-get-context)))
      (and ctx
           (if (eq (sgml-tag-type (car ctx)) 'close)
               (cons (sgml-get-context) ctx)
             (cons ctx (progn
                         (sgml-skip-tag-forward 1)
                         (backward-char 1)
                         (sgml-get-context))))))))

(defun hl-tags-update ()
  (let ((ctx (hl-tags-context)))
    (if (null ctx)
        (hl-tags-hide)
      (hl-tags-show)
      (move-overlay hl-tags-end-overlay
                    (sgml-tag-start (caar ctx))
                    (sgml-tag-end (caar ctx)))
      (move-overlay hl-tags-start-overlay
                    (sgml-tag-start (cadr ctx))
                    (sgml-tag-end (cadr ctx))))))

(defun hl-tags-show ()
  (unless hl-tags-start-overlay
    (setq hl-tags-start-overlay (make-overlay 1 1)
          hl-tags-end-overlay (make-overlay 1 1))
    (overlay-put hl-tags-start-overlay 'face 'show-paren-match-face)
    (overlay-put hl-tags-end-overlay 'face 'show-paren-match-face)))

(defun hl-tags-hide ()
  (when hl-tags-start-overlay
    (delete-overlay hl-tags-start-overlay)
    (delete-overlay hl-tags-end-overlay)))

(define-minor-mode hl-tags-mode
  "Toggle hl-tags-mode."
  nil "" nil
  (if hl-tags-mode
      (add-hook 'post-command-hook 'hl-tags-update nil t)
    (remove-hook 'post-command-hook 'hl-tags-update t)
    (hl-tags-hide)))


(provide 'hl-tags-mode)