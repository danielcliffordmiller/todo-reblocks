(defpackage todo
  (:use #:cl
	#:reblocks-ui/form
	#:reblocks/html)
  (:import-from #:reblocks/widget
		#:render
		#:update
		#:defwidget)
  (:import-from #:reblocks/actions
		#:make-js-action)
  (:import-from #:reblocks/app
		#:defapp))

(in-package :todo)

(defapp tasks
  :prefix "/")

(defvar *port* (find-port:find-port))

(reblocks/server:start :port *port*)

(defwidget task ()
  ((title
    :initarg :title
    :accessor title)
   (done
    :initarg :done
    :initform nil
    :accessor done)))

(defun make-task (title &key done)
  (make-instance 'task :title title :done done))

(defwidget task-list ()
  ((tasks
    :initarg :tasks
    :accessor tasks)))

(defmethod render ((task task))
  "Render a task."
  (with-html
    (:span
     (:input :type "checkbox"
	     :checked (done task)
	     :onclick (make-js-action
		       (lambda (&key &allow-other-keys)
			 (toggle task))))
     (if (done task)
	 (with-html
	   (:s (title task)))
	 (title task)))))

(defmethod render ((widget task-list))
  "Render a list of tasks."
  (with-html
    (:h1 "Tasks")
    (:div
     :style "display: grid; grid-template-columns: max-content min-content"
     (loop for task in (tasks widget) do
       (progn
	 (render task)
	 (render-link (lambda (&key &allow-other-keys)
    			     (remove-task task widget))
    			   "Delete"))))
    (with-html-form (:post (lambda (&key title &allow-other-keys)
			     (add-task widget title)))
      (:input :type "text"
	      :name "title"
	      :placeholder "Task's title")
      (:input :type "submit"
	      :value "Add"))))

(defun make-task-list (&rest rest)
  (let ((tasks (loop for title in rest
		     collect (make-task title))))
    (make-instance 'task-list :tasks tasks)))

(defmethod reblocks/page:init-page ((app tasks) url-path expire-at)
  (declare (ignorable app url-path expire-at))
  (make-task-list "Make my first Reblocks app"
		  "Deploy it somewhere"
		  "Have a profit"))

(defmethod add-task ((task-list task-list) title)
  (push (make-task title)
	(tasks task-list))
  (update task-list))

(defmethod remove-task ((task task) (task-list task-list))
  (setf (tasks task-list)
	(remove task (tasks task-list)))
  (update task-list))

(defmethod toggle ((task task))
  (setf (done task)
	(if (done task)
	    nil
	    t))
  (update task))
