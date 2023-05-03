(fn tailhelper [head ...]
  (if
    (> (length [...]) 0)
    [...]
    nil))
(fn tail [t] (tailhelper ((or table.unpack unpack) t)))

(fn any [cb list]
  (if
    (or (not list) (= 0 (length list))) false
    (if
      (cb (. list 1))
      true
      (any cb (tail list)))))

; returns true if callback returns true for every invocation
(fn every [cb list]
  (if
    (or (not list) (= 0 (length list))) true
    (if
      (cb (. list 1))
      (every cb (tail list))
      false)))


(fn find [cb list]
  (if
    (or (not list) (= 0 (length list))) nil
    (if
      (cb (. list 1))
      (. list 1)
      (find cb (tail list)))))


; returns true if any item in list1 exists in list 2
(fn has_common [list1 list2]
  (any
    (fn [list1_item]
      (any
        #(= list1_item $1)
        list2))
    list1))

; returns true if every item in list1 exists in list2
(fn has_all [list1 list2]
  (every
    (fn [list1_item]
      (any
        #(= list1_item $1)
        list2))
    list1)
  )

{
 :tail tail
 :any any
 :find find
 :has_common has_common
 :every every
 :has_all has_all
 }
