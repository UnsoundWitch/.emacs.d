;; init-boot.el -- init basic setting

;;; Commentary:
;; Edit the default Emacs config and internal pacakges

;;; Code:
(require 'init-const)

;; encoding
;; UTF-8 as the default coding system
(when (fboundp 'set-charset-priority)
  (set-charset-priority 'unicode))

;; gc hack
(use-package gcmh
  :diminish
  :init
  (setq gcmh-verbose             t
        gcmh-lows-cons-threshold #x800000
        gcmh-high-cons-threshold most-positive-fixnum
        gcmh-idle-delay          3600)
  :config
  (gcmh-mode))

;; display line number
(when sevil-use-linum
  (use-package linum
    :ensure nil
    :hook ((prog-mode text-mode org-mode) . linum-mode)))

;; load environment setting
;; if you can't use certain executable, please add it to the path
(when (or sys/mac-x-p sys/linux-x-p)
  (use-package exec-path-from-shell
    :init
    (setq exec-path-from-shell-check-startup-files nil
          exec-path-from-shell-variables '("PATH" "MANPATH")
          exec-path-from-shell-arguments '("-l"))
    (exec-path-from-shell-initialize)))

;; start server
(use-package server
  :ensure nil
  :defer 1
  :config
  (unless (server-running-p)
    (server-start)))

;; history
(use-package saveplace
  :ensure nil
  :hook (after-init . save-place-mode))

;; show recent files
(use-package recentf
  :ensure nil
  :hook (after-init . recentf-mode)
  :init (setq recentf-max-saved-items 300
              recentf-exclude
              '("\\.?cache" ".cask" "url" "COMMIT_EDITMSG\\'" "bookmarks"
                "\\.\\(?:gz\\|gif\\|svg\\|png\\|jpe?g\\|bmp\\|xpm\\)$"
                "\\.?ido\\.last$" "\\.revive$" "/G?TAGS$" "/.elfeed/"
                                        ;               "^/tmp/" "^/var/folders/.+$" ; "^/ssh:"
                (lambda (file) (file-in-directory-p file package-user-dir))))
  :config (push (expand-file-name recentf-save-file) recentf-exclude))

;; session management
(use-package savehist
  :ensure nil
  :hook (after-init . savehist-mode)
  :init (setq enable-recursive-minibuffers t ; Allow commands in minibuffers
              history-length 1000
              savehist-additional-variables '(mark-ring
                                              global-mark-ring
                                              search-ring
                                              regexp-search-ring
                                              extended-command-history)
              savehist-autosave-interval 300))

;; show information in modeline
(use-package simple
  :ensure nil
  :straight nil
  :hook
  ((after-init . (lambda ()
                   (line-number-mode)
                   (column-number-mode)
                   (size-indication-mode)))
   ((prog-mode markdown-mode conf-mode org-mode) . enable-trailing-whitespace))
  :init
  (setq ;; kill-whole-line t               ; Kill line including '\n'
   line-move-visual nil
   track-eol t                     ; Keep cursor at end of lines. Require line-move-visual is nil.
   set-mark-command-repeat-pop t)  ; Repeating C-SPC after popping mark pops it again

  ;; Visualize TAB, (HARD) SPACE, NEWLINE
  (setq-default show-trailing-whitespace nil) ; Don't show trailing whitespace by default
  (defun enable-trailing-whitespace ()
    "Show trailing spaces and delete on saving."
    (setq show-trailing-whitespace t)
    (add-hook 'before-save-hook #'delete-trailing-whitespace nil t)))

(setq-default major-mode 'text-mode
              fill-column 80
              tab-width 4
              indent-tabs-mode nil)     ; Permanently indent with spaces, never with TABs

(setq visible-bell t
      inhibit-compacting-font-caches t  ; Don’t compact font caches during GC.
      delete-by-moving-to-trash t       ; Deleting files go to OS's trash folder
      make-backup-files nil             ; Forbide to make backup files
      auto-save-default nil             ; Disable auto save

      uniquify-buffer-name-style 'post-forward-angle-brackets ; Show path if names are same
      adaptive-fill-regexp "[ t]+|[ t]*([0-9]+.|*+)[ t]*"
      adaptive-fill-first-line-regexp "^* *$"
      sentence-end "\\([。！？]\\|……\\|[.?!][]\"')}]*\\($\\|[ \t]\\)\\)[ \t\n]*"
      sentence-end-double-space nil)

(provide 'init-boot)
;;; init-boot.el ends here