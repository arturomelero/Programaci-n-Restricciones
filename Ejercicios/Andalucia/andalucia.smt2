sat
[ma = 1,
 ja = 1,
 hu = 1,
 al = 3,
 se = 2,
 co = 3,
 ca = 3,
 gr = 2]
; benchmark generated from python API
(set-info :status unknown)
(declare-fun hu () Int)
(declare-fun se () Int)
(declare-fun co () Int)
(declare-fun ja () Int)
(declare-fun ca () Int)
(declare-fun ma () Int)
(declare-fun gr () Int)
(declare-fun al () Int)
(assert
 (let (($x16 (<= hu 3)))
 (let (($x14 (>= hu 1)))
 (and $x14 $x16))))
(assert
 (>= se 1))
(assert
 (<= se 3))
(assert
 (>= co 1))
(assert
 (<= co 3))
(assert
 (>= ja 1))
(assert
 (<= ja 3))
(assert
 (>= ca 1))
(assert
 (<= ca 3))
(assert
 (>= ma 1))
(assert
 (<= ma 3))
(assert
 (>= gr 1))
(assert
 (<= gr 3))
(assert
 (>= al 1))
(assert
 (<= al 3))
(assert
 (and (distinct hu se) true))
(assert
 (and (distinct hu ca) true))
(assert
 (and (distinct se ca) true))
(assert
 (and (distinct se ma) true))
(assert
 (and (distinct se co) true))
(assert
 (and (distinct ca ma) true))
(assert
 (and (distinct ma co) true))
(assert
 (and (distinct ma gr) true))
(assert
 (and (distinct co ja) true))
(assert
 (and (distinct co gr) true))
(assert
 (and (distinct gr ja) true))
(assert
 (and (distinct gr al) true))
(check-sat)

