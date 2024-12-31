;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; doom exposes five (optional) variables for controlling fonts in doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; Set the primary font for Doom
(setq doom-font (font-spec :family "Hack Nerd Font" :size 22 :weight 'regular)
      ;; Non-monospace font for UI elements
      doom-variable-pitch-font (font-spec :family "Hack Nerd Font" :size 22)
      ;; For presentations or streaming
      doom-big-font (font-spec :family "Hack Nerd Font" :size 20))

;; Optional: Set additional fonts for symbols and serif text
(setq doom-symbol-font (font-spec :family "Hack Nerd Font" :size 22)
      doom-serif-font (font-spec :family "Hack Nerd Font" :size 22))
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-vibrant)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type 'relative)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

(require 'server)
(unless (server-running-p)
  (server-start))


(after! lsp-mode
  (setq lsp-log-io t))  ; Enable logging of LSP I/O communication


(use-package! treesit-auto
  :config
  (setq treesit-auto-install 'prompt)  ; Prompt before installing missing grammars
  (global-treesit-auto-mode))         ; Enable global Tree-sitter auto mode

(use-package! jtsx
  :mode
  (("\\.jsx?\\'" . jtsx-jsx-mode)
   ("\\.tsx\\'" . jtsx-tsx-mode))
  :config
  ;; Optional: Customize indentation levels
  (setq js-indent-level 2)
  (setq typescript-ts-mode-indent-offset 2)
  ;; Enable hideshow minor mode for code folding
  (add-hook 'jtsx-jsx-mode-hook 'hs-minor-mode)
  (add-hook 'jtsx-tsx-mode-hook 'hs-minor-mode)
  ;; Bind jtsx functions to convenient keybindings
  (map! :map jtsx-jsx-mode-map
        "C-c C-j" #'jtsx-jump-jsx-element-tag-dwim
        "C-c j o" #'jtsx-jump-jsx-opening-tag
        "C-c j c" #'jtsx-jump-jsx-closing-tag
        "C-c j r" #'jtsx-rename-jsx-element
        "C-c <down>" #'jtsx-move-jsx-element-tag-forward
        "C-c <up>" #'jtsx-move-jsx-element-tag-backward
        "C-c C-<down>" #'jtsx-move-jsx-element-forward
        "C-c C-<up>" #'jtsx-move-jsx-element-backward
        "C-c C-S-<down>" #'jtsx-move-jsx-element-step-in-forward
        "C-c C-S-<up>" #'jtsx-move-jsx-element-step-in-backward
        "C-c j w" #'jtsx-wrap-in-jsx-element
        "C-c j u" #'jtsx-unwrap-jsx
        "C-c j d" #'jtsx-delete-jsx-node
        "C-c j t" #'jtsx-toggle-jsx-attributes-orientation
        "C-c j h" #'jtsx-rearrange-jsx-attributes-horizontally
        "C-c j v" #'jtsx-rearrange-jsx-attributes-vertically)
  ;; Enable electric features
  (setq jtsx-enable-jsx-electric-closing-element t)
  (setq jtsx-enable-electric-open-newline-between-jsx-element-tags t))

(after! jtsx
  (map! :map jtsx-tsx-mode-map
        :n "gcc" #'jtsx-comment-dwim
        :v "gc"  #'jtsx-comment-dwim)

  (map! :map jtsx-jsx-mode-map
        :n "gcc" #'jtsx-comment-dwim
        :v "gc"  #'jtsx-comment-dwim))



;; Set standard indentation globally
(setq-default indent-tabs-mode nil) ;; Use spaces instead of tabs
(setq-default tab-width 2)          ;; Default tab width to 2 spaces
(setq-default standard-indent 2)    ;; Default indentation to 2 spaces

(use-package! copilot
  :hook (prog-mode . copilot-mode) ;; Enable Copilot in programming modes
  :config
;; Set 2-space indentation for specific modes, including `emacs-lisp-mode`
(setq copilot-indentation-alist
      '((emacs-lisp-mode 2)
        (lisp-interaction-mode 2) ;; For the scratch buffer and REPL
        (python-mode 2)           ;; Python indentation
        (js-mode 2)               ;; JavaScript
        (typescript-mode 2)       ;; TypeScript
        (typescript-ts-mode 2)    ;; Tree-sitter TypeScript mode
        (c-mode 2)                ;; C
        (c++-mode 2)              ;; C++
        (sh-mode 2)))             ;; Shell scripts
  ;; Bind Copilot functions
  (map! :i "C-<tab>" #'copilot-accept-completion                ;; Accept entire suggestion
        :i "C-<iso-lefttab>" #'copilot-accept-completion-by-word;; Accept suggestion word-by-word
        :i "C-c C-f" #'copilot-complete))

(use-package! org-roam
  :init
  (setq org-roam-directory (expand-file-name "~/org-roam"))
  :config
  (org-roam-db-autosync-mode))


(use-package! lsp-mode
  :hook ((typescript-ts-mode typescript-mode
          js-ts-mode js-mode) . lsp)
  :commands lsp)

(after! company
  (setq company-idle-delay 0.2          ;; Trigger completions instantly
        company-minimum-prefix-length 1)) ;; Trigger completions with a single character
