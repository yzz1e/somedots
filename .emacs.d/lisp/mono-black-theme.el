(deftheme mono-black
  "Pure black monochrome theme inspired by a minimal Neovim setup.")

(let (
      (bg "#000000")
      (fg "#b0b0b0")
      (dim "#505050")
      (gray "#707070")
      (light "#c8c8c8")
      (string "#999999")
      (number "#888888")
      (cursor "#181818"))

  (custom-theme-set-faces
   'mono-black

   ;; --- Base ---
   `(default ((t (:foreground ,fg :background ,bg))))
   `(cursor ((t (:background "#aaaaaa"))))
   `(fringe ((t (:background ,bg))))
   `(region ((t (:background "#202020"))))
   `(highlight ((t (:background ,cursor))))
   `(hl-line ((t (:background ,cursor))))

   ;; --- Line numbers ---
   `(line-number ((t (:foreground ,dim :background ,bg))))
   `(line-number-current-line ((t (:foreground "#aaaaaa" :background ,bg))))

   ;; --- Standard Syntax (Font Lock) ---
   `(font-lock-variable-name-face ((t (:foreground ,fg))))
   `(font-lock-function-name-face ((t (:foreground ,light))))
   `(font-lock-function-call-face ((t (:foreground "#c0c0c0"))))
   `(font-lock-type-face ((t (:foreground ,gray))))
   `(font-lock-constant-face ((t (:foreground ,gray)))) ;; Onde o Ciano costuma morar
   `(font-lock-builtin-face ((t (:foreground ,gray))))
   `(font-lock-keyword-face ((t (:foreground ,gray))))
   `(font-lock-preprocessor-face ((t (:foreground ,gray))))
   `(font-lock-string-face ((t (:foreground ,string))))
   `(font-lock-number-face ((t (:foreground ,number))))
   `(font-lock-comment-face ((t (:foreground ,dim :slant italic))))
   `(font-lock-doc-face ((t (:foreground ,dim))))
   `(font-lock-operator-face ((t (:foreground ,fg))))
   `(font-lock-property-name-face ((t (:foreground ,fg))))
   `(font-lock-property-use-face ((t (:foreground ,fg))))

   ;; --- Tree-sitter (Legacy package: tree-sitter-hl-face) ---
   `(tree-sitter-hl-face:variable ((t (:foreground ,fg))))
   `(tree-sitter-hl-face:variable.builtin ((t (:foreground ,gray))))
   `(tree-sitter-hl-face:function ((t (:foreground ,light))))
   `(tree-sitter-hl-face:function.call ((t (:foreground "#c0c0c0"))))
   `(tree-sitter-hl-face:type ((t (:foreground ,gray))))
   `(tree-sitter-hl-face:type.builtin ((t (:foreground ,gray))))
   `(tree-sitter-hl-face:keyword ((t (:foreground ,gray))))
   `(tree-sitter-hl-face:namespace ((t (:foreground ,gray)))) ;; Fix para o Ciano em namespaces
   `(tree-sitter-hl-face:property ((t (:foreground ,fg))))
   `(tree-sitter-hl-face:constant ((t (:foreground ,gray))))
   `(tree-sitter-hl-face:string ((t (:foreground ,string))))
   `(tree-sitter-hl-face:number ((t (:foreground ,number))))
   `(tree-sitter-hl-face:comment ((t (:foreground ,dim :slant italic))))
   `(tree-sitter-hl-face:operator ((t (:foreground ,fg))))
   `(tree-sitter-hl-face:punctuation ((t (:foreground ,dim))))
   `(tree-sitter-hl-face:punctuation.bracket ((t (:foreground ,dim))))
   `(tree-sitter-hl-face:punctuation.delimiter ((t (:foreground ,dim))))

   ;; --- Tree-sitter (Built-in Emacs 29+ faces) ---
   `(treesit-font-lock-number-face ((t (:foreground ,number))))
   `(treesit-font-lock-type-face ((t (:foreground ,gray))))
   `(treesit-font-lock-property-face ((t (:foreground ,fg))))
   `(treesit-font-lock-variable-name-face ((t (:foreground ,fg))))
   `(treesit-font-lock-function-name-face ((t (:foreground ,light))))
   `(treesit-font-lock-keyword-face ((t (:foreground ,gray))))

   ;; --- UI & Completion ---
   `(show-paren-match ((t (:foreground "#aaaaaa" :background "#202020"))))
   `(vertico-current ((t (:background nil :foreground "#ffffff" :weight bold))))
   `(dired-directory ((t (:foreground "#b0b0b0" :weight bold))))
   `(mode-line ((t (:foreground "#707070" :background "#000000" :box nil))))
   `(mode-line-inactive ((t (:foreground "#404040" :background "#000000" :box nil))))))

(provide-theme 'mono-black)
