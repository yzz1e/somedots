;; Initialize package manager and straight/vc
(require 'package)
(setq package-archives
      '(("gnu" . "https://elpa.gnu.org/packages/")
        ("melpa" . "https://melpa.org/packages/")))

(unless package--initialized
  (package-initialize))

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(require 'use-package)

;; Support for installing packages directly from Git
(unless (package-installed-p 'vc-use-package)
  (package-vc-install '(vc-use-package :vc-backend Git :url "https://github.com/slotThe/vc-use-package")))
(require 'vc-use-package)

;; Performance tuning
(setq gc-cons-threshold (* 524 1000 1000)
      read-process-output-max (* 16 1024 1024))

;; Minimal UI setup
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(blink-cursor-mode -1)
(fringe-mode 0)
(window-divider-mode -1)

(setq inhibit-startup-screen t
      initial-scratch-message nil
      cursor-type 'box
      left-fringe-width 0
      right-fringe-width 0
      window-divider-default-right-width 0
      window-divider-default-bottom-width 0)

(add-to-list 'default-frame-alist '(internal-border-width . 0))
(add-to-list 'default-frame-alist '(width . 120))
(add-to-list 'default-frame-alist '(height . 40))

(setq desktop-save-mode nil
      auto-image-file-mode t)
(desktop-save-mode -1)

;; Font configuration
(set-face-attribute 'default nil
                    :family "Iosevka"
                    :height 240
                    :weight 'normal
                    :slant 'normal)

;; Carrega o nosso tema Customizado: Pastel Ash
(add-to-list 'custom-theme-load-path (expand-file-name "lisp" user-emacs-directory))

(setq font-lock-maximum-decoration t)
(global-font-lock-mode 1)

;; Core editing behavior
(electric-indent-mode -1)
(setq-default indent-tabs-mode nil)
(setq make-backup-files nil
      create-lockfiles nil)

(global-hl-line-mode -1)
(delete-selection-mode 1)
(save-place-mode 1)
(mouse-avoidance-mode 'banish)
(winner-mode 1)

;; Line numbers and scrolling
(setq display-line-numbers-type 'relative)
(when (version<= "26.0.50" emacs-version)
  (global-display-line-numbers-mode))

(setq scroll-step 1
      scroll-conservatively 10000
      auto-window-vscroll nil
      scroll-margin 4)

;; Silent auto-revert
(setq auto-revert-use-notify t
      global-auto-revert-non-file-buffers t
      auto-revert-verbose nil)
(global-auto-revert-mode 1)

(defun my/auto-revert-only-if-clean ()
  (unless (buffer-modified-p)
    (auto-revert-handler)))

(add-hook 'after-revert-hook (lambda () (message nil)))

;; Shell environment
(setq shell-file-name "/bin/bash"
      explicit-shell-file-name "/bin/bash"
      vterm-shell "/bin/bash")

(global-set-key (kbd "M-TAB") #'hippie-expand)
(global-set-key (kbd "M-`") #'hippie-expand)
(global-set-key (kbd "C-z") #'undo)
(global-set-key (kbd "C-y") #'undo-redo)
(global-set-key (kbd "C-S-c") #'kill-ring-save)
(global-set-key (kbd "C-v") #'yank)
(global-set-key (kbd "C-S-v") #'yank)
(global-set-key (kbd "C-e") #'comment-line)
(global-set-key (kbd "C-a") #'mark-whole-buffer)
(global-set-key (kbd "C-0") #'my/text-scale-reset)
(global-set-key (kbd "C-0") (lambda () (interactive) (text-scale-set 0)))
(global-set-key (kbd "C-c f") #'toggle-frame-fullscreen)
(global-set-key (kbd "<f5>") #'recompile)

;; Smart navigation and editing macros
(defun my/smart-backward-kill ()
  "Smart backward kill mimicking IDE behavior without swallowing lines."
  (interactive)
  (if (use-region-p)
      (kill-region (region-beginning) (region-end))
    (let ((col (current-column)))
      (cond
       ((= col 0)
        (delete-char -1))
       ((save-excursion (backward-char col) (looking-at (format "^[ \t]\\{%d\\}$" col)))
        (let ((target-col (* (/ (- col 1) 4) 4)))
          (move-to-column target-col t)
          (delete-region (point) (progn (move-to-column col) (point)))
          (move-to-column target-col)))
       (t
        (backward-kill-word 1))))))

(global-set-key (kbd "<C-backspace>") #'my/smart-backward-kill)
(global-set-key (kbd "M-DEL") #'my/smart-backward-kill)
(define-key key-translation-map (kbd "C-h") (kbd "DEL"))
(define-key input-decode-map (kbd "ESC DEL") (kbd "C-<backspace>"))

(defun my/smarter-home ()
  "Move to indentation, or to start of line if already at indentation."
  (interactive "^")
  (let ((orig (point)))
    (back-to-indentation)
    (when (= orig (point))
      (beginning-of-line))))
(global-set-key (kbd "<home>") #'my/smarter-home)

(defun my/rename-buffer ()
  (interactive)
  (rename-buffer (read-string "New buffer name: ")))
(global-set-key (kbd "C-c r") 'my/rename-buffer)

(defun duplicate-line-below ()
  (interactive)
  (let ((col (current-column)))
    (save-excursion
      (let ((text (buffer-substring (line-beginning-position) (line-end-position))))
        (end-of-line)
        (newline)
        (insert text)))
    (forward-line 1)
    (move-to-column col)))

(defun duplicate-line-above ()
  (interactive)
  (let ((col (current-column))
        (text (buffer-substring (line-beginning-position) (line-end-position))))
    (beginning-of-line)
    (insert text "\n")
    (forward-line -1)
    (move-to-column col)))

(global-set-key (kbd "C-M-<down>") #'duplicate-line-below)
(global-set-key (kbd "C-M-<up>") #'duplicate-line-above)
(global-set-key (kbd "M-S-<down>") #'duplicate-line-below)
(global-set-key (kbd "S-M-<down>") #'duplicate-line-below)
(global-set-key (kbd "M-S-<up>") #'duplicate-line-above)
(global-set-key (kbd "S-M-<up>") #'duplicate-line-above)

(defun close-all-buffers ()
  "Kill all buffers except *scratch*."
  (interactive)
  (mapc (lambda (buffer)
          (unless (eq buffer (get-buffer "*scratch*"))
            (kill-buffer buffer)))
        (buffer-list))
  (switch-to-buffer "*scratch*"))

(global-set-key (kbd "M-n") (lambda () (interactive) (forward-line 5)))
(global-set-key (kbd "M-p") (lambda () (interactive) (forward-line -5)))

(defun my-jump-down ()
  (interactive)
  (forward-line (read-number "Down lines: ")))
(defun my-jump-up ()
  (interactive)
  (forward-line (- (read-number "Up lines: "))))
(global-set-key (kbd "C-c j d") #'my-jump-down)
(global-set-key (kbd "C-c j u") #'my-jump-up)

;; Compilation window management
(setq compilation-window-height 15)
(add-to-list 'display-buffer-alist
             '("\\*compilation\\*"
               (display-buffer-reuse-window
                display-buffer-at-bottom)
               (window-height . 15)))

(defun my/close-compilation-window ()
  (interactive)
  (let ((win (get-buffer-window "*compilation*")))
    (when win
      (delete-window win))))

(global-set-key (kbd "C-c c") #'my/close-compilation-window)
(global-set-key (kbd "M-;") #'recompile)

;; Visual bookmark marker
(defface my-marker-face
  '((t (:background "#cc0000" :foreground "#ffffff")))
  "Face for temporary visual marker.")

(defvar my-marker-overlay nil)
(defvar my-marker-position nil)

(defun my/bm-mark ()
  "Set a temporary visual red marker at point."
  (interactive)
  (when my-marker-overlay
    (delete-overlay my-marker-overlay))
  (setq my-marker-position (copy-marker (point)))
  (setq my-marker-overlay
        (make-overlay (point) (min (1+ (point)) (point-max))))
  (overlay-put my-marker-overlay 'face 'my-marker-face)
  (message "Marker set"))

(defun my/bm-jump ()
  "Jump to temporary marker and remove it."
  (interactive)
  (if (and my-marker-position (marker-position my-marker-position))
      (progn
        (goto-char my-marker-position)
        (when my-marker-overlay
          (delete-overlay my-marker-overlay)
          (setq my-marker-overlay nil))
        (set-marker my-marker-position nil)
        (setq my-marker-position nil)
        (message "Marker jumped"))
    (message "No marker set")))

(global-set-key (kbd "C-c b m") #'my/bm-mark)
(global-set-key (kbd "C-c b n") #'my/bm-jump)

;; Treesitter & Major Modes
(use-package simpc-mode
  :vc (:fetcher github :repo "rexim/simpc-mode")
  :ensure t)

(setq major-mode-remap-alist
      '((js-mode . js-ts-mode)
        (css-mode . css-ts-mode)))

(add-to-list 'auto-mode-alist '("\\.\\(c\\|h\\)\\'" . c-ts-mode))
(add-to-list 'auto-mode-alist '("\\.\\(cpp\\|hpp\\)\\'" . c++-ts-mode))
(add-to-list 'auto-mode-alist '("\\.js\\'" . js-ts-mode))
(setq treesit-font-lock-level 4)

;; Packages
(use-package vterm
  :ensure t
  :config
  (setq vterm-always-compile t
        vterm-max-scrollback 10000))

(use-package web-mode
  :ensure t
  :mode ("\\.html?\\'" "\\.jsx\\'" "\\.tsx\\'")
  :config
  (setq web-mode-enable-auto-closing t
        web-mode-enable-auto-pairing nil
        web-mode-enable-current-element-highlight t))
        
(with-eval-after-load 'web-mode
  (set-face-attribute 'web-mode-current-element-highlight-face nil
                      :background "#2a2a2a"
                      :foreground 'unspecified
                      :weight 'normal))

(use-package emmet-mode
  :ensure t
  :hook ((html-mode . emmet-mode)
         (web-mode . emmet-mode)
         (css-mode . emmet-mode)))

(use-package yasnippet
  :ensure t
  :config
  (yas-global-mode 1))

(use-package yasnippet-snippets
  :ensure t)

(use-package move-text
  :ensure t
  :bind (("M-<up>" . move-text-up)
         ("M-<down>" . move-text-down)))

(use-package multiple-cursors
  :ensure t
  :bind (("C-c m" . mc/mark-next-like-this)
         ("C-c l" . mc/mark-next-like-this-word)
         ("C-c C-v" . mc/edit-lines)
         ("C-M-<mouse-1>" . mc/add-cursor-on-click)
         ("C-M-S-<down>" . mc/mark-next-like-this)
         ("C-M-S-<up>" . mc/mark-previous-like-this))
  :init
  (setq mc/always-run-for-all t)
  :config
  (add-to-list 'mc/cmds-to-run-for-all 'my/smart-backward-kill))

;; Dired
(require 'dired-x)
(setq dired-omit-files (concat dired-omit-files "\\|^\\..+$")
      dired-dwim-target t
      dired-listing-switches "-alh")
(put 'dired-find-alternate-file 'disabled nil)

(with-eval-after-load 'dired
  (define-key dired-mode-map (kbd "RET") 'dired-find-alternate-file)
  (define-key dired-mode-map (kbd "^") 'dired-up-directory)
  (setq hl-line-sticky-flag nil)
  (hl-line-mode -1))

(defun my/dired-here ()
  (interactive)
  (let ((dir (if (buffer-file-name)
                 (file-name-directory (buffer-file-name))
               default-directory)))
    (kill-this-buffer)
    (dired dir)))

(defun my/dired-here-prompt ()
  (interactive)
  (let ((dir (read-directory-name "Dired directory: " default-directory)))
    (switch-to-buffer (dired-noselect dir))))

(global-set-key (kbd "C-x C-j") 'my/dired-here)
(global-set-key (kbd "C-c d") 'my/dired-here-prompt)

;; Vertico / Orderless / Marginalia / Consult
(use-package vertico
  :init
  (vertico-mode))

(use-package orderless
  :custom
  (completion-styles '(orderless)))

(use-package marginalia
  :init
  (marginalia-mode 1))

(use-package consult
  :bind (("C-f" . consult-line)
         ("M-f" . consult-buffer)
         ("C-s" . save-buffer)))

;; LSP (Eglot) Configuration
(use-package eglot
  :ensure t
  :hook ((js-ts-mode . eglot-ensure)
         (typescript-ts-mode . eglot-ensure)
         (html-mode . eglot-ensure)
         (css-mode . eglot-ensure)
         (web-mode . eglot-ensure)
         (simpc-mode . eglot-ensure)
         (c-ts-mode . eglot-ensure)
         (c++-ts-mode . eglot-ensure)
         (odin-ts-mode-hook . eglot-ensure))
  :config
  (setq eglot-autoshutdown t
        eglot-confirm-server-initiated-edits nil
        eglot-events-buffer-size 0)

  ;; Disable intrusive server capabilities
  (setq eglot-ignored-server-capabilities
        '(:documentFormattingProvider
          :documentRangeFormattingProvider
          :documentOnTypeFormattingProvider
          :codeActionProvider
          :codeLensProvider
          :inlayHintProvider
          :documentHighlightProvider))
  
  ;; Keep Eglot out of syntax checking and indent handling
  (add-to-list 'eglot-stay-out-of 'flymake)
  (add-to-list 'eglot-stay-out-of 'indent)

  (add-to-list 'eglot-server-programs
               '((js-ts-mode typescript-ts-mode) . ("typescript-language-server" "--stdio")))
  (add-to-list 'eglot-server-programs
               '((html-mode web-mode) . ("vscode-html-language-server" "--stdio")))
  (add-to-list 'eglot-server-programs
               '((css-mode) . ("vscode-css-language-server" "--stdio")))
  (add-to-list 'eglot-server-programs
               '((c-ts-mode c++-ts-mode simpc-mode) . ("clangd" "--header-insertion=never" "--clang-tidy=false"))))

(add-hook 'eglot-managed-mode-hook
          (lambda ()
            (flymake-mode -1)

            (unless (or (derived-mode-p 'odin-mode)
                        (derived-mode-p 'odin-ts-mode))
              )

            (when (fboundp 'eglot-inlay-hints-mode)
              (eglot-inlay-hints-mode -1))))

;; Autocompletion
(use-package company
  :ensure t
  :hook (eglot-managed-mode . company-mode)
  :config
  (setq company-idle-delay nil
        company-minimum-prefix-length 1
        company-format-margin-function nil))

;; Manual C/C++ Formatting & Dumb TAB
(defun my/c-indent-line ()
  "Insert 4 spaces only (Dumb TAB)."
  (interactive)
  (insert "    "))

(defun my/clang-format-region ()
  "Format current C/C++ block via CLI."
  (interactive)
  (let ((start (line-beginning-position))
        (end (line-end-position))
        (column (current-column)))
    (shell-command-on-region start end "clang-format" t t)
    (move-to-column column)))

(defun my/clang-format-buffer ()
  "Format entire C/C++ buffer via CLI."
  (interactive)
  (let ((line (line-number-at-pos))
        (column (current-column)))
    (shell-command-on-region (point-min) (point-max) "clang-format" t t)
    (goto-char (point-min))
    (forward-line (1- line))
    (move-to-column column)))

(defun my/clang-format-style ()
  "Generate a local .clang-format style file."
  (interactive)
  (let* ((spaces (read-number "Indent spaces: " 4))
         (allman (y-or-n-p "Allman style? "))
         (style (if allman "Allman" "Attach"))
         (content
          (format "BasedOnStyle: LLVM\n\nIndentWidth: %d\n\nBreakBeforeBraces: %s\n" spaces style)))
    (with-temp-file "~/.clang-format"
      (insert content))
    (message "clang-format: %d spaces, %s" spaces (if allman "Allman" "K&R"))))

(defun my/setup-clang-format-keys ()
  "Configura atalhos locais para o clang-format."
  (local-set-key (kbd "<C-tab>") #'my/clang-format-buffer)
  (local-set-key (kbd "C-TAB") #'my/clang-format-buffer)
  (local-set-key (kbd "C-c f") #'my/clang-format-buffer))

(add-hook 'simpc-mode-hook #'my/setup-clang-format-keys)
(add-hook 'c-ts-mode-hook #'my/setup-clang-format-keys)
(add-hook 'odin-ts-mode-hook #'eglot-ensure)
(add-hook 'c++-ts-mode-hook #'my/setup-clang-format-keys)

;; Store auto-generated settings in a temp file
(setq custom-file (make-temp-file "emacs-custom"))

;; Whitespace mode (O estilo purista do Tsoding)
(defun rc/set-up-whitespace-handling ()
  (interactive)
  (whitespace-mode 0)
  ;; Remove espaços inúteis no fim da linha automaticamente ao salvar
  (add-to-list 'write-file-functions 'delete-trailing-whitespace))

(setq whitespace-style '(face spaces space-mark))

(setq whitespace-display-mappings
      '((tab-mark ?\t [?\→ ?\s] [?\→ ?\s])
        (space-mark ?\s [?\·] [?\s])))

(global-whitespace-mode 0)
(setq auto-save-default nil
      make-auto-save-file-name nil)

(defun my/dumb-tab ()
  "Insert tab-width spaces."
  (interactive)
  (insert (make-string tab-width ?\s)))

(defun my/newline-copy-indent ()
  "Enter burro, mas inteligente com linhas vazias."
  (interactive)
  (let ((indent
         (save-excursion
           (beginning-of-line)
           (if (looking-at "^[ \t]*$")
               ""
             (buffer-substring (point)
                               (progn
                                 (back-to-indentation)
                                 (point)))))))
    (newline)
    (insert indent)))

(defun my/enable-dumb-tab ()
  "Make TAB insert spaces and Enter copy indent in editing buffers only."
  (local-set-key (kbd "TAB") #'my/dumb-tab)
  (local-set-key (kbd "<tab>") #'my/dumb-tab)
  (local-set-key (kbd "RET") #'my/newline-copy-indent)
  (local-set-key (kbd "<return>") #'my/newline-copy-indent))

(add-hook 'prog-mode-hook #'my/enable-dumb-tab)
(add-hook 'text-mode-hook #'my/enable-dumb-tab)

(setq-default tab-width 4)
(defun tab-width ()
  "Change tab width dynamically."
  (interactive)
  (setq-default tab-width
                (read-number "Width: " tab-width))
  (message "Tab width set to %d" tab-width))
  
(use-package fasm-mode
  :vc (:fetcher github :repo "emacsattic/fasm-mode")
  :ensure t
  :mode "\\.asm\\'")
  
(unless (package-installed-p 'odin-mode)
  (package-vc-install "https://github.com/mattt-b/odin-mode"))

;; Instala o go-mode tradicional do MELPA para servir de fallback e trazer o gofmt
(use-package go-mode
  :ensure t)

;; Sequestra o modo padrão e joga pro Tree-sitter (se Emacs 29+)
(when (fboundp 'go-ts-mode)
  (add-to-list 'major-mode-remap-alist '(go-mode . go-ts-mode))
  (add-to-list 'major-mode-remap-alist '(go-mod-mode . go-mod-ts-mode)))

(defun my/go-setup ()
  "Configurações de baixo nível pro ambiente Go."
  (setq tab-width 4)
  
  (eglot-ensure)
  
  (add-hook 'before-save-hook #'gofmt-before-save nil t)
  
  (local-set-key (kbd "M-.") #'xref-find-definitions)   ;; Goto Def
  (local-set-key (kbd "M-,") #'xref-pop-marker-stack)   ;; Voltar de onde veio
  (local-set-key (kbd "M-?") #'xref-find-references))   ;; Achar referências

(add-hook 'go-ts-mode-hook #'my/go-setup)

(setq native-comp-async-report-warnings-errors 'silent)
(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               '((go-mode go-ts-mode) . ("/home/aktty/go/bin/gopls"))))

(add-hook 'makefile-mode-hook
          (lambda ()
            (setq indent-tabs-mode t)))

;; Força o Emacs a ignorar o ASCII e tratar/exibir tudo como UTF-8
(setq coding-system-for-read 'utf-8)
(setq coding-system-for-write 'utf-8)
(set-language-environment 'utf-8)

(setq-default buffer-file-coding-system 'utf-8-unix)

(with-eval-after-load 'eglot
  (add-hook 'eglot-managed-mode-hook
            (lambda ()
              (setq-local mode-line-misc-info
                          (cl-remove-if
                           (lambda (x)
                             (and (listp x)
                                  (eq (car x) 'eglot--managed-mode)))
                           mode-line-misc-info)))))

(defun toggle-tab-behavior ()
  "Toggle between using real TAB characters and spaces.
When using spaces, it enforces the 'dumb-tab' behavior."
  (interactive)
  (if indent-tabs-mode
      (progn
        (setq indent-tabs-mode nil)
        (setq tab-width (read-number "Set space indentation width: " tab-width))
        (local-set-key (kbd "TAB") #'my/dumb-tab)
        (local-set-key (kbd "<tab>") #'my/dumb-tab)
        (message "Mode set to Spaces (width: %d)" tab-width))
    (progn
      (setq indent-tabs-mode t)
      (setq tab-width (read-number "Set tab width: " tab-width))
      (local-unset-key (kbd "TAB"))
      (local-unset-key (kbd "<tab>"))
      (message "Mode set to Real TABs (width: %d)" tab-width))))

(with-eval-after-load 'make-mode
  (set-face-attribute 'makefile-space nil
                      :foreground "#555555"
                      :background "unspecified"
                      :inherit nil))

(add-hook 'compilation-finish-functions
          (lambda (buffer status)
            (when (string-match "finished" status)
              (switch-to-buffer-other-window buffer))))

(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               '(odin-mode . ("ols"))))

(use-package odin-mode
  :ensure t)

(add-to-list 'treesit-language-source-alist
             '(odin "https://github.com/noughts/tree-sitter-odin"))

(use-package odin-ts-mode
  :vc (:fetcher github
       :repo "Sampie159/odin-ts-mode")
  :mode "\\.odin\\'"
  :config
  (setq odin-ts-mode-indent-offset 4))

(add-to-list 'treesit-language-source-alist
             '(odin "https://github.com/amaanq/tree-sitter-odin"))
(defun my/shell-command-fullscreen (command)
  "Run shell COMMAND in the current directory, showing output in a fullscreen buffer."
  (interactive
   (list
    (read-shell-command "Shell command: ")))

  (shell-command command "*Shell Command Output*")
  (pop-to-buffer "*Shell Command Output*")
  (delete-other-windows))

(global-set-key (kbd "C-M-!") #'my/shell-command-fullscreen)
(defun my/python-setup ()
  (setq-local python-indent-offset 4)
  (setq-local tab-width 4)
  (setq-local indent-tabs-mode nil))

(add-hook 'python-ts-mode-hook #'my/python-setup)
(add-hook 'python-mode-hook #'my/python-setup)
(use-package eglot
  :ensure nil
  :config
  (add-to-list 'eglot-server-programs
               '((ruby-mode ruby-ts-mode)
                 . ("/home/aktty/.local/share/gem/ruby/3.4.0/bin/solargraph" "stdio")))
  :hook
  (ruby-ts-mode . eglot-ensure))
  
(use-package ruby-ts-mode
  :mode (("\\.rb\\'" . ruby-ts-mode)
         ("\\.rake\\'" . ruby-ts-mode)
         ("\\.gemspec\\'" . ruby-ts-mode)
         ("\\.ru\\'" . ruby-ts-mode)
         ("Gemfile\\'" . ruby-ts-mode)
         ("Rakefile\\'" . ruby-ts-mode))
  :hook
  ((ruby-ts-mode . eldoc-mode)
   (ruby-ts-mode . eglot-ensure)))
   
(eldoc-mode 1)

(use-package scala-ts-mode
  :mode (("\\.scala\\'" . scala-ts-mode)))

;; Deixei apenas o essencial no footer custom
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-vc-selected-packages
   '((simpc-mode :vc-backend Git :url
                 "https://github.com/rexim/simpc-mode")
     (vc-use-package :vc-backend Git :url
                     "https://github.com/slotThe/vc-use-package"))))
;;(add-hook 'after-change-major-mode-hook
;;          (lambda ()
;;            (set-face-attribute
;;             'font-lock-function-name-face
;;             nil
;;             :foreground (face-attribute 'default :foreground))))
(with-eval-after-load 'company
  (define-key company-mode-map (kbd "C-SPC") #'company-complete))
(set-face-attribute 'line-number nil
                    :inherit 'default)

(set-face-attribute 'line-number-current-line nil
                    :inherit 'line-number)
;; Gruber Darker Theme
;;(use-package gruber-darker-theme
;;  :vc (:fetcher github :repo "rexim/gruber-darker-theme")
;;  :ensure t
;;  :config
;;  (load-theme 'gruber-darker t))
;;(package-vc-install
;; '(c3-ts-mode :url "https://github.com/c3lang/c3-ts-mode"))
(use-package c3-ts-mode
  :mode (("\\.c3\\'" . c3-ts-mode)))
(add-to-list 'treesit-language-source-alist
             '(c3 "https://github.com/c3lang/tree-sitter-c3"))
(global-set-key (kbd "C-S-s") #'isearch-forward)
(require 'ansi-color)

;; Paleta ANSI (0-7)
(setq ansi-color-names-vector
      ["#3B3F45"   ; preto
       "#D38A8A"   ; vermelho
       "#9FC59F"   ; verde
       "#D7C08A"   ; amarelo
       "#8FAFD7"   ; azul
       "#C3A1C9"   ; magenta
       "#8FC4C9"   ; ciano
       "#C8CDD4"]) ; branco

;; Paleta usada por term/comint
(setq ansi-term-color-vector
      [unspecified
       "#3B3F45"
       "#D38A8A"
       "#9FC59F"
       "#D7C08A"
       "#8FAFD7"
       "#C3A1C9"
       "#8FC4C9"
       "#C8CDD4"])

;; Compilação
(defun my/colorize-compilation-buffer ()
  (let ((inhibit-read-only t))
    (ansi-color-apply-on-region
     compilation-filter-start
     (point))))

(add-hook 'compilation-filter-hook #'my/colorize-compilation-buffer)

;; Helper genérico pra colorir qualquer buffer temporário de shell
(defun my/colorize-buffer (buf-name)
  (when-let ((buf (get-buffer buf-name)))
    (with-current-buffer buf
      (let ((inhibit-read-only t))
        (ansi-color-apply-on-region (point-min) (point-max))))))

;; Shell Command (M-! síncrono e assíncrono)
(defun my/colorize-shell-command-buffer (&rest _)
  (my/colorize-buffer "*Shell Command Output*")
  (my/colorize-buffer "*Async Shell Command*"))

(advice-add 'shell-command :after #'my/colorize-shell-command-buffer)

;; Garante renderização em buffers genéricos do temp-buffer-setup-hook
(add-hook 'temp-buffer-show-hook
          (lambda ()
            (when (string-match-p "^\\*.*Shell Command.*\\*$" (buffer-name))
              (let ((inhibit-read-only t))
                (ansi-color-apply-on-region (point-min) (point-max))))))
(use-package d-mode
  :mode ("\\.d\\'" . d-mode))

(add-to-list 'auto-mode-alist '("\\.d\\'" . d-mode))
(add-to-list
 'treesit-language-source-alist
 '(d "https://github.com/tree-sitter-grammars/tree-sitter-d"))
;; Aponta para o Emacs onde estão os seus temas customizados
(add-to-list 'custom-theme-load-path (expand-file-name "~/.emacs.d/lisp/"))

;; Carrega o seu tema direto.
;; Esse 't' no final serve para ele confiar no código e não ficar
;; te pedindo confirmação de segurança (safe-local-variable) toda vez que abrir o editor.
;; (load-theme 'SOME-THEME t)
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
(add-to-list 'custom-theme-load-path
             (expand-file-name "~/.emacs.d/lisp/"))

(load-theme 'gruber-darker t)
(add-to-list 'default-frame-alist
             '(alpha-background . 100))
