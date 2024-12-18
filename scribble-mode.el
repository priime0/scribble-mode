;;; scribble-mode.el --- Major mode for editing Scribble documents -*- lexical-binding: t; -*-

;; Copyright (c) 2014 Mario Rodas <marsam@users.noreply.github.com>
;; Copyright (c) 2024 Lucas Sta Maria <lucas@priime.dev>

;; Author: Mario Rodas <marsam@users.noreply.github.com>, Lucas Sta Maria <lucas@priime.dev>
;; URL: https://github.com/priime0/scribble-mode
;; Keywords: convenience
;; Version: 0.1
;; Package-Requires: ((emacs "29"))

;; This file is NOT part of GNU Emacs.

;;; License:

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
;; A major mode for editing Scribble documents.

;;; Code:

(defgroup scribble-mode nil
  "Major mode for editing Scribble documents."
  :prefix "scribble-mode-"
  :group 'languages)

(defcustom scribble-mode-executable "scribble"
  "Path to scribble executable."
  :type 'string
  :group 'scribble-mode)

(defvar scribble-mode-imenu-generic-expression
  `(("Title"
     ,(rx "@title" (? (: "[" (* (not (any "]")))) "]") "{" (group (+ (not (any "}")))) "}")
     1)
    ("Section"
     ,(rx "@" (* "sub") "section" (? (: "[" (* (not (any "]")))) "]") "{" (group (+ (not (any "}")))) "}")
     1)))

(defvar scribble-mode-syntax-table
  (let ((table (make-syntax-table)))
    ;; Whitespace
    (modify-syntax-entry ?\t "    " table)
    (modify-syntax-entry ?\n ">   " table)
    (modify-syntax-entry ?\f "    " table)
    (modify-syntax-entry ?\r "    " table)
    (modify-syntax-entry ?\s "    " table)

    (modify-syntax-entry ?\" "\"   " table)
    (modify-syntax-entry ?\\ "\\   " table)

    ;; Special characters
    (modify-syntax-entry ?' "'   " table)
    (modify-syntax-entry ?` "'   " table)
    (modify-syntax-entry ?, "'   " table)
    (modify-syntax-entry ?@ "'   " table)

    ;; Comments
    (modify-syntax-entry ?\@ "' 1" table)
    (modify-syntax-entry ?\; "' 2" table)
    (modify-syntax-entry ?\n ">"   table)

    (modify-syntax-entry ?# "w 14" table)

    ;; Brackets and braces balance for editing convenience.
    (modify-syntax-entry ?\[ "(]  " table)
    (modify-syntax-entry ?\] ")[  " table)
    (modify-syntax-entry ?{  "(}  " table)
    (modify-syntax-entry ?}  "){  " table)
    (modify-syntax-entry ?\( "()  " table)
    (modify-syntax-entry ?\) ")(  " table)
    table)
  "Syntax table for `scribble-mode'.")

(defvar scribble-mode-font-lock-keywords
  `((,(rx bol (group "#lang") (+ space) (group (1+ not-newline)))
     (1 font-lock-keyword-face)
     (2 font-lock-variable-name-face))
    ;; keyword arguments
    (,(rx (group "#:" (+ (not (any space ")")))))
     (1 font-lock-keyword-face))
    ;; #t #f
    (,(regexp-opt '("#t" "#true" "#f" "#false") 'symbols)
     (1 font-lock-constant-face))
    (,(rx (group "@" (+ (not (any space "[" "{" "("))))) ; FIXME
     (1 font-lock-function-name-face)))
  "Font lock for `scribble-mode'.")

;;;###autoload
(define-derived-mode scribble-mode prog-mode "Scribble"
  "Major mode for editing scribble files.

\\{scribble-mode-map}"
  (set (make-local-variable 'comment-start) "@;")
  (set (make-local-variable 'comment-end) "")
  (set (make-local-variable 'comment-multi-line) nil)
  (set (make-local-variable 'font-lock-defaults)
       '(scribble-mode-font-lock-keywords))
  (set (make-local-variable 'imenu-generic-expression)
       scribble-mode-imenu-generic-expression)
  (imenu-add-to-menubar "Contents"))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.scrbl\\'" . scribble-mode))

;;;; Keybindings:

(defun scribble-mode-balance (char)
  "Insert CHAR and balance it."
  (let ((closing
         (pcase char
           ("(" ")")
           ("{" "}")
           ("[" "]")
           (_ ""))))
    (insert char)
    (insert closing)
    (backward-char)))

(defun scribble-mode-open-paren ()
  "Insert balanced parentheses."
  (interactive)
  (scribble-mode-balance "("))

(defun scribble-mode-open-brace ()
  "Insert balanced curly braces."
  (interactive)
  (scribble-mode-balance "{"))

(defun scribble-mode-open-bracket ()
  "Insert balanced brackets."
  (interactive)
  (scribble-mode-balance "["))

(keymap-set scribble-mode-map "(" #'scribble-mode-open-paren)
(keymap-set scribble-mode-map "{" #'scribble-mode-open-brace)
(keymap-set scribble-mode-map "[" #'scribble-mode-open-bracket)

(provide 'scribble-mode)

;;; scribble-mode.el ends here
