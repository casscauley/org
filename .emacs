;; before using org/ln.sh do the following
;; M-x list-packages
;; find org
;; i + x (highlight install and install)
(require 'package)
(package-initialize)

(unless package-archive-contents
  (package-refresh-contents))

(add-to-list 'load-path "~/org/.emacs.d/")

;; remove auto-newline because many projects don't have it
(setq require-final-newline nil)
(setq mode-require-final-newline nil)
(add-hook 'org-mode-hook 'toggle-truncate-lines)

;; nuke auto indent because I don't play like that
(electric-indent-mode -1)

;; Lock files make chokidar freak out
(setq create-lockfiles nil)

;; show all tabs
(require 'highlight-chars)
(add-hook 'font-lock-mode-hook 'hc-highlight-tabs)

;highlight trailing whitespace
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages (quote (vue-mode rjsx-mode)))
 '(show-trailing-whitespace t))

; unsure if this is still relevant, I think electric-indent-mode covers it
;(define-key global-map (kbd "RET") 'newline)
;(add-hook 'html-mode-hook '(lambda ()
;                             (local-set-key (kbd "RET") 'newline)))

; get the *~ files out of sight
(setq backup-directory-alist '(("" . "~/.emacs.d/emacs-backup")))

(setq auto-save-visited-interval 300)

(add-to-list 'auto-mode-alist'("\\.js\\'" . rjsx-mode))
(add-to-list 'auto-mode-alist '("\\.jscad\\'" . rjsx-mode))
(add-to-list 'auto-mode-alist '("\\.json\\'" . js-mode))
(add-to-list 'auto-mode-alist '("\\.jsx\\'" . js-mode))
(add-to-list 'auto-mode-alist '("\\.ts\\'" . js-mode))
(add-to-list 'auto-mode-alist '("\\.tsx\\'" . js-mode))
(add-to-list 'auto-mode-alist '("\\.tag\\'" . html-mode))
(add-to-list 'auto-mode-alist '("\\.html\\'" . html-mode))
(setq js2-strict-missing-semi-warning nil)
(add-to-list 'auto-mode-alist '("\\.less\\'" . css-mode))
(add-to-list 'auto-mode-alist '("\\.scss\\'" . css-mode))
(add-to-list 'auto-mode-alist '("\\.md\\'" . rst-mode))
(add-to-list 'auto-mode-alist '("\\.tpl\\'" . html-mode))
(add-to-list 'auto-mode-alist '("\\.org$" . org-mode))
(define-key global-map "\C-cl" 'org-store-link)
(define-key global-map "\C-ca" 'org-agenda)
(setq org-log-done t)
(setq org-agenda-files (list "~/org/"))
(setq org-agenda-files (list "~/org/memcached.org"
                             "~/org/pipedreams.org"
                             "~/Dropbox/org/"))

; export INDENT=number to set global value for indent
(setq my-width 2)
(setq-default default-tab-width 2)
(if (getenv "INDENT")
    (setq my-width (string-to-number (getenv "INDENT")))
    (setq tab-width my-width)
    (setq default-tab-width 2)
    )

(setq css-indent-offset my-width)
(setq js-indent-level my-width)
(setq javascript-indent-level my-width)

(setq-default python-indent-offset my-width);
(add-hook 'python-mode-hook
    (lambda () (setq tab-width my-width)))
(setq html-indent-offset my-width)
(setq-default indent-tabs-mode nil)
(setq default-tab-width my-width)
(add-hook 'rjsx-mode-hook (lambda()(setq tab-width my-width)))
(add-hook 'js-mode-hook (lambda()(setq tab-width my-width)))
(add-hook 'javascript-mode-hook (lambda()(setq tab-width my-width)))
(add-hook 'html-mode-hook (lambda()(setq tab-width my-width)))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
 ;; custom-set-faces was added by Custom.

(defun xah-comment-dwim ()
  "Like `comment-dwim', but toggle comment if cursor is not at end of line.

URL `http://ergoemacs.org/emacs/emacs_toggle_comment_by_line.html'
Version 2016-10-25"
  (interactive)
  (if (region-active-p)
      (comment-dwim nil)
    (let (($lbp (line-beginning-position))
          ($lep (line-end-position)))
      (if (eq $lbp $lep)
          (progn
            (comment-dwim nil))
        (if (eq (point) $lep)
            (progn
              (comment-dwim nil))
          (progn
            (comment-or-uncomment-region $lbp $lep)
            ))))))

(global-set-key (kbd "M-;") 'xah-comment-dwim)
(setq column-number-mode t)

(menu-bar-mode -1)
