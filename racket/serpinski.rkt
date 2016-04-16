#lang racket

(require racket/draw)

(define WIDTH 4500)
(define HEIGHT 4000)

;A list of the points of the initial equilateral triangle
;The first point is the bottom-left
;The second point is top
;The third point is the bottom-right
(define initial-triangle (list (make-object point% 10 (- HEIGHT 10))
                               (make-object point% (/ WIDTH 2) 10)
                               (make-object point% (- WIDTH 10) (- HEIGHT 10))))

;The bitmap to draw
(define target (make-bitmap WIDTH HEIGHT)) 

;dc stands for Drawing Context
(define dc (new bitmap-dc% [bitmap target])) ; The % indicates a class

;Draw initial triangle
(send dc draw-polygon initial-triangle)

;Creates an upside down equilateral triangle in the middle of given equilateral
;triangle and number of iterations
;The points of the upside down triangle will be represented in the following
;way:
;The top-left point is A
;The top-right point is B
;The bottom point is C
(define (create-subtriangle triangle iterations)
  ;; TODO Gotta fix this shit. The x values of points A and B are messed up.
  (let* ([tri-height (- (send (first triangle) get-y) (send (second triangle)
                                                            get-y))]
         ;Length of a side of large triangle
         [tri-length (distance (first triangle) (third triangle))];LGTM
         ;Length of a side of sub-triangle
         [sub-length (/ tri-length 2)];LGTM
         ;Height of sub-triangle
         ;WTF I did some fucking math wrong? Or something. I'm off by like 50
         ;somehow
         [sub-height (+ 50 (ceiling(* (sin (degrees->radians 60)) sub-length)))]
         ;It definitely has something to do with sub-height. Because A and B are
         ;the only things messing up.
         [A (make-object point% (+ (send (first triangle) get-x)
                                   (/ sub-length 2))
                         (- (send (first triangle) get-y)
                            sub-height))]
         [B (make-object point% (- (send (third triangle) get-x)
                                   (/ sub-length 2))
                         (- (send (first triangle) get-y)
                            sub-height))]
         [C (make-object point% (send (second triangle) get-x)
                         (send (third triangle) get-y))]
         [sub-triangle (list A B C)]
         ;These are the right-side up equilaterals created from the upside down
         ;sub triangle
         [leg1 (list (first triangle) A C)];Bottom left
         [leg2 (list A (second triangle) B)];Top
         [leg3 (list C B (third triangle))]);Bottom right
    (when (> iterations 0)
      (send dc set-brush "black" 'solid)
      (send dc draw-polygon sub-triangle)
      (create-subtriangle leg1 (- iterations 1))
      (create-subtriangle leg2 (- iterations 1))
      (create-subtriangle leg3 (- iterations 1)))))

;What is the distance between given points a and b?
(define (distance a b)
  (let* ([x2 (send b get-x)]
         [x1 (send a get-x)]
         [y2 (send b get-y)]
         [y1 (send a get-y)])
    (sqrt (+ (expt (- x2 x1) 2) (expt (- y2 y1) 2)))))

(create-subtriangle initial-triangle 4)

(send target save-file "serpinski.png" 'png)
