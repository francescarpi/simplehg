;;; simplehg.el --- Control Hg from Emacs.

;; Copyright (C) 2014 Francesc Arpí.

;; Author: Francesc Arpi <farpi@apsl.net>
;; URL: https://github.com/francescarpi/simplehg.git
;; Version: 0.2 Beta
;; Keywords: tools, mercurial, hg

;; SimpleHg is free software: you can redistribute it and/or modify it
;; under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; SimpleHg is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;; Utils
(defun simplehg-face-format1(text)
  (propertize text 'face '(:foreground "orange" 
			   :weight bold)))

(defun simplehg-face-format2(text)
  (propertize text 'face '(:foreground "color-196" 
			   :weight bold)))

(defun simplehg-face-format3(text)
  (propertize text 'face '(:foreground "color-82" 
			   :weight bold)))

(defun simplehg-message(message)
  (message (simplehg-face-format1 message)))

(defun simplehg-get-line-file-name()
  (substring (buffer-substring (line-beginning-position) (line-end-position)) 2))

(defun simplehg-get-line-file-path()
  (concat (simplehg-root) "/" (simplehg-get-line-file-name)))

;; Key bindings
(defvar simplehg-status-buffer-map
  (let ((map (make-keymap)))
    (define-key map (kbd "c") 'simplehg-make-commit)
    (define-key map (kbd "r") 'simplehg-status-buffer)
    (define-key map (kbd "A") 'simplehg-addremove)
    (define-key map (kbd "P") 'simplehg-push)
    (define-key map (kbd "N") 'simplehg-push-new-branch)
    (define-key map (kbd "b") 'simplehg-select-branch)
    (define-key map (kbd "M") 'simplehg-merge-branch)
    (define-key map (kbd "U") 'simplehg-pull-update)
    (define-key map (kbd "D") 'simplehg-delete-file)
    (define-key map (kbd "f") 'simplehg-diff)
    (define-key map (kbd "R") 'simplehg-revert)
    (define-key map (kbd "t") 'simplehg-create-new-branch)
    map))

(defvar simplehg-commit-buffer-map
  (let ((map (make-keymap)))
    (define-key map (kbd "C-c C-c") 'simplehg-do-commit)
    (define-key map (kbd "C-c C-l") 'simplehg-do-commit-close-branch)
    map))

(defvar simplehg-pull-update-map
  (let ((map (make-keymap)))
    (define-key map (kbd "c") 'simplehg-close-pull-buffer)
    map))

;; Main functions
(defun simplehg-status()
  (interactive)  
  (shell-command-to-string "hg st"))

(defun simplehg-root()
  "Return ht root path"
  (substring (shell-command-to-string "hg root") 0 -1))

(defun simplehg-current-branch()
  (substring (shell-command-to-string "hg branch") 0 -1))

(defun simplehg-status-buffer()
  "Show Hg Status Buffer"

  (interactive)

  (get-buffer-create "simplehg")
  (pop-to-buffer "simplehg")
  (erase-buffer)
  (use-local-map simplehg-status-buffer-map)

  (insert (simplehg-face-format1 "\nSimpleHG: Status Buffer\n"))
  (insert (simplehg-face-format1 "=======================\n\n"))

  (insert (concat "Repository path: " (simplehg-root) "\n"))
  (insert (concat "Current branch: " (simplehg-face-format2 (simplehg-current-branch)) "\n"))
  (insert (concat "Last refresh time: " (format-time-string "%H:%M:%S") "\n\n"))
  
  (insert (simplehg-face-format1 "Changes\n"))
  (insert (simplehg-face-format1 "-------\n\n"))

  (if (equal (simplehg-status) "")
      (insert (simplehg-face-format3 "Not changes found\n"))
      (insert (simplehg-status)))

  (insert (simplehg-face-format1 "\nMap Keys\n"))
  (insert (simplehg-face-format1 "--------\n\n"))
  (insert "r: Refresh status\n\n")

  (insert "c: Make a commit\n")
  (insert "P: Make a push to remote repository\n")
  (insert "N: Make a push to with --new-branch param\n")
  (insert "U: Hg pull/update\n\n")

  (insert "b: Change to other branch\n")
  (insert "t: Create a new branch\n")
  (insert "M: Merge with other branch\n\n")

  (insert "A: Execute hg addremove command\n")
  (insert "f: View differences\n")
  (insert "R: Revert file\n")
  (insert "D: Delete selected file\n")

  (goto-line 12))


(defun simplehg-make-commit()
  (interactive)

  (if (equal (simplehg-status) "")
      (error "Not changes found. Commit its not possible."))

  (get-buffer-create "simplehg-commit")
  (pop-to-buffer "simplehg-commit")
  (erase-buffer)
  (use-local-map simplehg-commit-buffer-map)
  (simplehg-message "C-c C-c: commit  |  C-c C-l: commit --close-branch  |  C-x k: cancel commit")
)

(defun simplehg-do-commit()
  (interactive)

  (when (= (buffer-size) 0)
    (error "Empty buffer. Is not possible to commit.  Type C-x k to cancel."))

  (write-file "simplehg-commit")
  (shell-command-to-string (concat "hg commit --logfile simplehg-commit"))
  (delete-file "simplehg-commit")

  (kill-buffer "simplehg-commit")
  (simplehg-status-buffer)
  (simplehg-message "Commit finished successfully"))

;; TODO: Repeated code with do-commit. Improve.
(defun simplehg-do-commit-close-branch()
  (interactive)

  (when (= (buffer-size) 0)
    (error "Empty buffer. Is not possible to commit.  Type C-x k to cancel."))

  (write-file "simplehg-commit")
  (shell-command-to-string (concat "hg commit --logfile simplehg-commit --close-branch"))
  (delete-file "simplehg-commit")

  (kill-buffer "simplehg-commit")
  (simplehg-status-buffer)
  (simplehg-message "Commit finished successfully"))

(defun simplehg-push()
  (interactive)
  (simplehg-message "Running 'hg push'")

  (shell-command-to-string "hg push")
  (simplehg-status-buffer)

  (simplehg-message "Push finished successfully"))


(defun simplehg-push-new-branch()
  (interactive)
  (simplehg-message "Running 'hg push --new-branch'")

  (shell-command-to-string "hg push --new-branch")
  (simplehg-status-buffer)

  (simplehg-message "Push finished successfully"))


(defun simplehg-jump-branch(branch_name)
  (interactive "MBranch name: ")
  (shell-command-to-string (concat "hg up " branch_name))
  (simplehg-status-buffer))

(defun simplehg-branch-list()
  (split-string (shell-command-to-string "hg branches") "\n"))

(defun simplehg-select-branch(branch_name)
  (interactive (list (completing-read "Branch name: " (simplehg-branch-list))))
  (simplehg-jump-branch (nth 0 (split-string branch_name " "))))

(defun simplehg-merge-branch(branch_name)
  (interactive (list (completing-read "Branch name: " (simplehg-branch-list))))
  (shell-command-to-string (concat "hg merge " (nth 0 (split-string branch_name " "))))
  (simplehg-status-buffer)
  (simplehg-message "Merge finished successfully"))

(defun simplehg-addremove()
  (interactive)

  (if (equal (simplehg-status) "")
      (error "Not changes found. Addremove its not possible."))

  (shell-command-to-string "hg addremove")
  (simplehg-status-buffer))

(defun simplehg-pull-update()
  (interactive)
  (get-buffer-create "simplehg-update")
  (pop-to-buffer "simplehg-update")
  (erase-buffer)
  (use-local-map simplehg-pull-update-map)

  (simplehg-message "Running 'hg pull -uv'")

  (insert (simplehg-face-format1 "\nPull Log\n"))
  (insert (simplehg-face-format1 "--------\n\n"))
  (insert (shell-command-to-string "hg pull -uv"))
  (insert (simplehg-face-format1 "\nPress 'c' to close\n")))

(defun simplehg-close-pull-buffer()
  (interactive)
  (kill-buffer "simplehg-update")
  (simplehg-status-buffer))

(defun simplehg-delete-file()
  (interactive)
  (when (yes-or-no-p (concat "Do you want delete this file '" (simplehg-get-line-file-name) "'? "))
    (delete-file (simplehg-get-line-file-path)))
  (simplehg-status-buffer))

(defun simplehg-diff()
  (interactive)
  (setq simplehg-file-path (simplehg-get-line-file-path))
  (get-buffer-create "simplehg-diff")
  (pop-to-buffer "simplehg-diff")
  (erase-buffer)
  (insert (shell-command-to-string (concat "hg diff " simplehg-file-path)))
  (diff-mode))

(defun simplehg-revert()
  (interactive)
  (when (yes-or-no-p (concat "Do you want revert this file '" (simplehg-get-line-file-name) "'? "))
    (shell-command-to-string (concat "hg revert " (simplehg-get-line-file-path))))
  (simplehg-status-buffer))

(defun simplehg-create-new-branch(name)
  (interactive "MBranch name: ")
  (shell-command-to-string (concat "hg branch " name))
  (simplehg-status-buffer))


(provide 'simplehg)

