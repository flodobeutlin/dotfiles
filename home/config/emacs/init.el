;; init --- My personal init -*- lexical-binding: t; -*-
;;; Commentary:

;;; Code:
;;; functions for configuration ============================
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

(require 'setup)
(setup-define :load-after
  (lambda (&rest features)
    (let ((body `(require ',(setup-get 'feature))))
      (dolist (feature (nreverse features))
        (setq body `(with-eval-after-load ',feature ,body)))
      body))
  :documentation "Load the current feature after FEATURES.")

(require 'cl-lib)

(defmacro set! (&rest args)
  "Customize user options with ARGS like `setq'."
  (declare (debug setq))
  `(progn ,@(cl-loop for (name val) on args by #'cddr
                                        ;if (null val) return (user-error "Not enough arguments")
                     collecting `(customize-set-variable ',name ,val)
                     into ret
                     finally return ret)))

(defmacro defmap! (name &rest bindings )
  "Define a keymap NAME with defined BINDINGS."
  `(progn (defvar ,name
            (let ((keymap (make-keymap)))
              ,@(cl-loop for (key val) on bindings by #'cddr
                         collecting `(define-key keymap ,key ,val)
                         into ret
                         finally return ret)
              keymap))
          (defalias ',name ,name)))

;;; basic settings =========================================
(set! inhibit-startup-message t
      vc-follow-symlinks t       ; do not warn when following symlinks
      visible-bell nil           ; do not flash a visual bell
      window-resize-pixelwise t  ; more flexible resizing
      frame-resize-pixelwise t
      use-dialog-box nil)

;; only in emacs >= 28
(when (boundp 'use-short-answers)
  (set! use-short-answers t))

;; customization
(set! custom-file
      (locate-user-emacs-file "custom.el"))
(when (file-exists-p custom-file)
  (load custom-file))

;; backups
(setq backup-directory-alist
      `(("." . ,(expand-file-name ".backups" user-emacs-directory))))
(set! auto-save-default nil
      backup-by-copying t
      delete-old-versions t
      create-lockfiles nil)

;;; ui =====================================================

(set-fringe-mode 10)                    ; add padding to frame
(set! blink-cursor-mode nil)            ; do not blink cursor

;; theme
(setup modus-themes
  (:option modus-themes-italic-constructs t
           modus-themes-bold-constructs t
           modus-themes-region '(accented)
           modus-themes-mode-line '(accented borderless)
           modus-themes-tabs-accented t
           modus-themes-paren-match '(intense bold))
  (load-theme 'modus-operandi t)

  (custom-set-faces
   '(mode-line ((t (:background "white smoke"))))))

;; font
(custom-set-faces
 '(default ((t (:weight regular :height 140 :family "JuliaMono")))))

;; modeline
(setup mood-line
  (mood-line-mode))

(column-number-mode t)

(setup popper
  (:option popper-mode t
           popper-echo-mode t))

;;; editor =================================================
(set! tab-width 4
      indent-tabs-mode nil)

;; kill ring
(set! save-interprogram-paste-before-kill t
      kill-do-not-save-duplicates t)

;; insert brackets,parens,... as pairs
(setup elec-pair
  (:option electric-pair-mode t))

;; show matching parentheses
(setup paren
  (:option show-paren-mode t
           show-paren-delay 0
           show-paren-context-when-offscreen t))

;; indenting
(setup aggressive-indent
  (:hook-into prog-mode))

;; editorconfig
(setup editorconfig
  (:option editorconfig-mode t))

;; buffer-env
(setup buffer-env)

;; scrolling
(set! scroll-margin 1
      scroll-step   1
      scroll-conservatively 101
      scroll-preserve-screen-position t
      fast-but-imprecise-scrolling t)

;;; completion =============================================
(setup vertico
  (require 'vertico)
  (:option vertico-cycle t
           vertico-resize nil)
  (vertico-mode))

(setup corfu
  (require 'corfu)
  (:option corfu-auto t
           corfu-auto-delay 0
           corfu-preview-current nil
           corfu-cycle t
           corfu-echo-documentation 0.25
           tab-always-indent 'complete)
  (global-corfu-mode))

(setup consult
  (:option completion-in-region-function
           #'consult-completion-in-region))

(setup orderless
  (:option completion-styles '(orderless basic)))

(setup marginalia
  (:option marginalia-mode t))

(setup (:package savehist recentf)
  ;; history
  (:option savehist-mode t
           history-delete-duplicates t
           history-length 1000
           savehist-save-minibuffer-history t)
  ;; recent files
  (:option recentf-mode t)
  ;; position in files
  (:option save-place-mode t))

;; snippets
(setup tempel
  (defun tempel-setup-capf ()
    "Setup tempel as a capf backend."
    (setq-local completion-at-point-functions
                (cons #'tempel-expand
                      completion-at-point-functions)))
  (:bind-into tempel-map
    "TAB" #'tempel-next)
  (:global
   "M-+" #'tempel-expand
   "M-*" #'tempel-insert))

(add-hook 'prog-mode-hook #'tempel-setup-capf)
(add-hook 'text-mode-hook #'tempel-setup-capf)

;; help
(set! help-window-select t)

;;; applications ===========================================
;; calendar
(set! calendar-week-start-day 1
      calendar-date-style 'iso)
(set! calendar-holidays
      '((holiday-fixed 1 1      "Neujahr")
        (holiday-fixed 1 6      "Heilige Drei Könige")
        (holiday-fixed 10 3     "Tag der Deutschen Einheit")
        (holiday-float 12 0 -4  "1. Advent" 24)
        (holiday-float 12 0 -3  "2. Advent" 24)
        (holiday-float 12 0 -2  "3. Advent" 24)
        (holiday-float 12 0 -1  "4. Advent" 24)
        (holiday-fixed 12 25    "1. Weihnachtstag")
        (holiday-fixed 12 26    "2. Weihnachtstag")
        (holiday-easter-etc -48 "Rosenmontag")
        (holiday-easter-etc -3  "Gründonnerstag")
        (holiday-easter-etc  -2 "Karfreitag")
        (holiday-easter-etc   0 "Ostersonntag")
        (holiday-easter-etc  +1 "Ostermontag")
        (holiday-easter-etc +39 "Christi Himmelfahrt")
        (holiday-easter-etc +49 "Pfingstsonntag")
        (holiday-easter-etc +50 "Pfingstmontag")
        (holiday-easter-etc +60 "Fronleichnam")
        (holiday-fixed 8 15     "Mariä Himmelfahrt")
        (holiday-fixed 11 1     "Allerheiligen")
        (holiday-float 11 3 1   "Buß- und Bettag" 16))
      calendar-mark-holidays-flag t)

;; eshell
(setup eshell
  (:option eshell-banner-message ""))

;;; development ============================================

(setup prog-mode
  (:hook #'display-line-numbers-mode
         #'hs-minor-mode))

;; git
(setup (:package magit diff-hl)
  (:load-after meow flymake)
  ;; magit
  (:option magit-define-global-key-bindings nil)
  (:bind-into magit-mode-map
    "x" #'magit-discard
    "J" #'meow-next-expand
    "K" #'meow-prev-expand
    "L" #'magit-log)
  ;; diff in margin
  (require 'diff-hl)
  (:with-mode diff-hl-mode
    (:hook-into prog-mode)
    (add-hook 'magit-pre-refresh-hook  #'diff-hl-magit-pre-refresh)
    (add-hook 'magit-post-refresh-hook #'diff-hl-magit-post-refresh)))

;; compilation
(set! compilation-scroll-output 'first-error
      compilation-ask-about-save nil)

;; ide
(setup (:package eglot flymake xref)
  ;; eglot
  (:option eglot-autoshutdown t
           eldoc-echo-area-use-multiline-p nil
           eldoc-idle-delay 0.2
           eglot-confirm-server-initiated-edits nil)
  ;; flymake
  (:with-mode flymake-mode
    (:hook-into prog-mode))
  
  (:option help-at-pt-display-when-idle t)

  ;; xref
  (:option xref-search-program 'ripgrep
           xref-show-xrefs-function #'consult-xref
           xref-show-definitions-function #'consult-xref))

;;; prose languages ========================================
;; HTML

(setup (:package web-mode rainbow-mode)
  (:with-mode web-mode
    (:file-match "\\.html?\\'"))
  (require 'rainbow-mode)
  (:with-mode rainbow-mode
    (:load-after flymake-mode)
    (:hook-into prog-mode)))

;; LaTeX
(setup auctex
  (:with-mode TeX-mode
    (:hook #'visual-line-mode
           #'TeX-fold-mode
           #'LaTeX-math-mode
           #'reftex-mode))
  (:option TeX-master 'dwim
           TeX-engine 'luatex
           TeX-PDF-mode t
           TeX-auto-save t
           TeX-parse-self t
           TeX-electric-math '("$" . "$")
           LaTeX-electric-left-right-brace t))

;; org
(setup (:package org org-superstar)
  (:with-mode org
    (:hook #'org-indent-mode
           #'visual-line-mode
           #'org-superstar-mode))
  (:option org-ellipsis " ↴"
           org-highlight-latex-and-related '(latex script entities)
           org-pretty-entities t
           org-preview-latex-image-directory
           (expand-file-name
            "ltxpng"
            (temporary-file-directory))
           org-src-window-setup 'current-window)
  (:option org-html-doctype "xhtml5"
           org-html-html5-fancy t)
  (:option org-superstar-special-todo-items t
           org-superstar-leading-bullet ?\s))


(defconst org-electric-pairs
  '((?$ . ?$)))
(add-hook 'org-mode-hook
          (defun org-add-electric-pairs ()
            (setq-local electric-pair-pairs (append electric-pair-pairs org-electric-pairs)
                        electric-pair-text-pairs electric-pair-pairs)))


;;; programming languages ==================================
;; agda
(setup agda2-mode
  (defun local/init-agda ()
  "Initialise agda mode."
  (when (executable-find "agda-mode")
    (load-file (let ((coding-system-for-read 'utf-8))
                 (shell-command-to-string "agda-mode locate")))))
  (local/init-agda)

  (:hook #'local/disable-aggressive-indent))


;; apl
(setup gnu-apl-mode)
;; c/c++
(setup cc-mode
  (:load-after eglot)
  (:hook #'eglot-ensure))

;; coq
(defun local/setup-pg-faces ()
  "Setup faces for Proof General."
  (set-face-background 'proof-locked-face "#90ee90"))

(setup proof-general
  (:option proof-splash-enable nil
           proof-three-window-enable t
           proof-three-window-mode-policy 'vertical
           proof-delete-empty-windows t)
  (:with-mode coq-mode
    (:hook #'local/setup-pg-faces)))

;; lisp
(setup sly
  (:with-mode lisp-mode
    (:hook #'sly-editing-mode)))

(setup (:package geiser geiser-guile geiser-racket)
  (:option scheme-program-name "guile"))

(setup eros
  (:with-mode emacs-lisp-mode
    (:hook #'eros-mode))
  (:with-mode lisp-mode
    (:hook #'eros-mode)))

;; haskell
(setup haskell-mode
  (:load-after eglot)
  (:hook #'eglot-ensure
         #'interactive-haskell-mode)
  (:option haskell-completing-read-function #'completing-read))

;; java
(setup antlr-mode)

;; js
(setup (:package js2-mode json-mode)
  (:with-mode js2-mode
    (:file-match "\\.js\\'")))

;; nix

(setup nix-mode
  (defconst nix-electric-pairs
    '(("let" . " in")
      (?= . ";")))
  (defun nix-add-electric-pairs ()
    (setq-local electric-pair-pairs
                (append electric-pair-pairs nix-electric-pairs)
                electric-pair-text-pairs electric-pair-pairs))
  (:file-match "\\.nix\\'")
  (:hook #'nix-add-electric-pairs))

(add-hook 'nix-mode-hook
          (defun nix-add-electric-pairs ()
            (setq-local electric-pair-pairs (append electric-pair-pairs nix-electric-pairs)
                        electric-pair-text-pairs electric-pair-pairs)))


;; prolog
(setup (:package prolog ediprolog)
  (:with-mode prolog
    (:file-match "\\.pl\\'"))
  (:option prolog-system 'scryer
           ediprolog-system 'scryer))

;; rust
(setup (:package rust-mode cargo)
  (:load-after eglot)
  (:with-mode rust-mode
    (:hook #'eglot-ensure)))

;;; utilities ==============================================

(defun local/split-window-right ()
  "Like 'split-window-right' , but ask for buffer."
  (interactive)
  (split-window-right)
  (consult-buffer-other-window))

(defun local/split-window-below ()
  "Like 'split-window-below' , but ask for buffer."
  (interactive)
  (split-window-below)
  (consult-buffer-other-window))

(defun local/fill-line (&optional max-column char)
  "Fill rest of current line with CHAR upto column MAX-COLUMN."
  (interactive)
  (or max-column (setq max-column 60))
  (or char (setq char ?=))
  (save-excursion
    (end-of-line)
    (let* ((col (current-column))
           (n (- max-column col)))
      (if (> n 0)
          (insert (make-string n char))))))

(defun local/unix-epoch-show (point)
  "Convert unix epoch at POINT to timestamp and show in overlay."
  (interactive "d")
  (let* ((time-unix (seconds-to-time (thing-at-point 'number)))
         (time-zone "UTC")
         (time-str (format-time-string "%Y-%m-%d %a %H:%M:%S" time-unix time-zone) ))
    (eros--eval-overlay time-str (point))))

(defun local/indent-buffer ()
  "Reformat the whole buffer."
  (interactive)
  (save-excursion
    (indent-region (point-min) (point-max) nil)))

(defun local/mutate-int-at-point (f)
  "Replace integer at point with the result of calling F on it."
  (interactive "aEnter a function:")
  (let ((n (thing-at-point 'number)))
    (if (numberp n)
        (save-excursion
          (message (symbol-name (type-of f)))
          (skip-chars-backward "-0123456789")
          (if (looking-at "-?[0-9]+")
              (let* ((start (point))
                     (end (match-end 0)))
                (delete-region start end)
                (insert (number-to-string (funcall f n))))))
      (message "No number at point"))))

(defun local/inc-at-point ()
  "Increment integer at point."
  (interactive)
  (local/mutate-int-at-point #'1+))

(defun local/dec-at-point ()
  "Decrement integer at point."
  (interactive)
  (local/mutate-int-at-point #'1-))

(defun local/disable-aggressive-indent ()
  "Disable 'aggressive-indent-mode'."
  (interactive)
  (aggressive-indent-mode -1))

;;; keybindings ============================================

(defmap! app-keymap
         "a" #'org-agenda
         "c" #'calc
         "m" #'gnus
         "t" #'eshell)

(defmap! buffer-keymap
         "b" #'consult-buffer
         "k" #'kill-this-buffer
         "r" #'rename-buffer
         "R" #'revert-buffer)

(defmap! project-keymap
         "c" #'project-compile
         "f" #'project-find-file
         "g" #'magit-status
         "r" #'consult-ripgrep
         "t" #'neotree)

(defmap! search-keymap
         "i" #'consult-imenu
         "o" #'consult-outline
         "s" #'consult-line)

(defmap! window-keymap
         "d" #'delete-window
         "D" #'delete-other-windows
         "s" #'local/split-window-right
         "S" #'local/split-window-below
         "p" #'popper-toggle-latest
         "P" #'popper-toggle-type

         "j" #'windmove-down
         "k" #'windmove-up
         "h" #'windmove-left
         "l" #'windmove-right)
(setup meow
  (:option meow-cheatsheet-layout meow-cheatsheet-layout-qwerty
           meow-use-clipboard t
           meow-expand-hint-remove-delay 0)
  (require 'meow)
  (meow-motion-overwrite-define-key
   '("j" . meow-next)
   '("k" . meow-prev)
   '("h" . meow-left)
   '("l" . meow-right)
   '("<escape>" . ignore))
  (meow-leader-define-key
   '("j" . "H-j")
   '("k" . "H-k")
   '("h" . "H-h")
   '("l" . "H-l")
   '("u" . undo-redo)
   '(":" . execute-extended-command)
   '(";" . pp-eval-expression)
   '("." . find-file)
   '("," . consult-buffer)
   '("TAB" . hs-toggle-hiding)
   '("a" . app-keymap)
   '("b" . buffer-keymap)
   '("p" . project-keymap)
   '("s" . search-keymap)
   '("w" . window-keymap)

   '("1" . meow-digit-argument)
   '("2" . meow-digit-argument)
   '("3" . meow-digit-argument)
   '("4" . meow-digit-argument)
   '("5" . meow-digit-argument)
   '("6" . meow-digit-argument)
   '("7" . meow-digit-argument)
   '("8" . meow-digit-argument)
   '("9" . meow-digit-argument)
   '("0" . meow-digit-argument)
   '("/" . meow-keypad-describe-key)
   '("?" . meow-cheatsheet))

  (meow-normal-define-key
   '("0" . meow-expand-0)
   '("9" . meow-expand-9)
   '("8" . meow-expand-8)
   '("7" . meow-expand-7)
   '("6" . meow-expand-6)
   '("5" . meow-expand-5)
   '("4" . meow-expand-4)
   '("3" . meow-expand-3)
   '("2" . meow-expand-2)
   '("1" . meow-expand-1)
   '("-" . negative-argument)
   '(";" . meow-reverse)
   '("," . meow-inner-of-thing)
   '("." . meow-bounds-of-thing)
   '("[" . meow-beginning-of-thing)
   '("]" . meow-end-of-thing)
   '("a" . meow-append)
   '("A" . meow-open-below)
   '("b" . meow-back-word)
   '("B" . meow-back-symbol)
   '("c" . meow-change)
   '("d" . meow-delete)
   '("D" . meow-backward-delete)
   '("e" . meow-next-word)
   '("E" . meow-next-symbol)
   '("f" . meow-find)
   '("g" . meow-cancel-selection)
   '("G" . meow-grab)
   '("h" . meow-left)
   '("H" . meow-left-expand)
   '("i" . meow-insert)
   '("I" . meow-open-above)
   '("j" . meow-next)
   '("J" . meow-next-expand)
   '("k" . meow-prev)
   '("K" . meow-prev-expand)
   '("l" . meow-right)
   '("L" . meow-right-expand)
   '("m" . meow-join)
   '("n" . meow-search)
   '("o" . meow-block)
   '("O" . meow-to-block)
   '("p" . meow-yank)
   '("q" . meow-quit)
   '("Q" . meow-goto-line)
   '("r" . meow-replace)
   '("R" . meow-swap-grab)
   '("s" . meow-kill)
   '("t" . meow-till)
   '("u" . meow-undo)
   '("U" . meow-undo-in-selection)
   '("v" . meow-visit)
   '("w" . meow-mark-word)
   '("W" . meow-mark-symbol)
   '("x" . meow-line)
   '("X" . meow-goto-line)
   '("y" . meow-save)
   '("Y" . meow-sync-grab)
   '("z" . meow-pop-selection)
   '("'" . repeat)
   '("<escape>" . ignore))
  (meow-global-mode t))



;;; init.el ends here
