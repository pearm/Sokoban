;=============================================================
; PRAM 2011
; Senaste ändring: Implementerat stöd för animering 2011-04-09
;
; Projekt: Sokoban
; Mattias Fransson, Marcus Eriksson, grupp 4, Y1a
;
; Fil: draw.scm
; Beskrivning: Definierar de funktioner som sköter uppritning.
;=============================================================

; Klass
(define draw-object%
  (class object%
    
    ; Konstruktorvärden
    (init-field canvas)
    
    ; Lokala fält
    (field 
     ; Funktionella variabler
     (refresh? #t)
     (canvas-width *game-canvas-width*)
     (canvas-height *game-canvas-height*)
     (map-width (send *current-board* get-width))
     (map-height (send *current-board* get-height))
     (block-size 36)
     (gif-delay 50)
     (dc (send canvas get-dc))
     (active-gifs '())
     
     ; Konstanta verktyg
     (background-colour (make-colour 0 34 102))
     (player-colour (make-colour 178 34 34))
     (block-colour (make-colour 94 64 51))
     (floor-colour (make-colour 159 182 205))
     (wall-colour (make-colour 0 0 0))
     (goal-colour (make-colour 255 215 0))
     (power-up-colour (make-colour 60 179 113))
     
     ; PNGs
     (player-png (make-object bitmap% "data/textures/player.png" 'png/mask))
     (player-mask (send player-png get-loaded-mask))
     (background-png (make-object bitmap% "data/textures/background.png"))
     (block-png (make-object bitmap% "data/textures/block.png"))
     (floor-png (make-object bitmap% "data/textures/floor.png"))
     (goal-png (make-object bitmap% "data/textures/goal.png"))
     (wall-png (make-object bitmap% "data/textures/wall.png"))
     
     ; Gifs
     (star-list
      (list (make-object bitmap% "data/animations/star/star1.png" 'png/mask)
            (make-object bitmap% "data/animations/star/star2.png" 'png/mask)
            (make-object bitmap% "data/animations/star/star3.png" 'png/mask)
            (make-object bitmap% "data/animations/star/star4.png" 'png/mask)
            (make-object bitmap% "data/animations/star/star5.png" 'png/mask)))
     
     (blink-list
      (list (make-object bitmap% "data/animations/blink/gif1.png" 'png/mask)
            (make-object bitmap% "data/animations/blink/gif2.png" 'png/mask)
            (make-object bitmap% "data/animations/blink/gif3.png" 'png/mask)
            (make-object bitmap% "data/animations/blink/gif4.png" 'png/mask)
            (make-object bitmap% "data/animations/blink/gif5.png" 'png/mask)
            (make-object bitmap% "data/animations/blink/gif6.png" 'png/mask)
            (make-object bitmap% "data/animations/blink/gif7.png" 'png/mask)
            (make-object bitmap% "data/animations/blink/gif8.png" 'png/mask)))         
     
     ; Brushes
     (no-brush (make-object brush% "WHITE" 'transparent))
     (background-brush (make-object brush% background-colour 'solid))
     (black-brush (make-object brush% "BLACK" 'solid))
     (blue-brush (make-object brush% "BLUE" 'solid))
     (red-brush (make-object brush% "RED" 'solid))
     (green-brush (make-object brush% "GREEN" 'solid))
     (yellow-brush (make-object brush% "YELLOW" 'solid))
     (brown-brush (make-object brush% "BROWN" 'solid))
     (player-brush (make-object brush% player-colour 'solid))
     (block-brush (make-object brush% block-colour 'solid))
     (floor-brush (make-object brush% floor-colour 'solid))
     (wall-brush (make-object brush% wall-colour 'solid))
     (goal-brush (make-object brush% goal-colour 'solid))
     (power-up-brush (make-object brush% power-up-colour 'solid))
     
     ; Pens
     (no-pen (make-object pen% "WHITE" 1 'transparent))
     (background-pen (make-object pen% background-colour 1 'solid))
     (black-pen (make-object pen% "BLACK" 1 'solid))
     (black-pen2 (make-object pen% "BLACK" 2 'solid)))
    
    ; #### Private ####
    
    ; Fyller hela canvas med bakgrundsbilden
    (define/private (fill-canvas)
      (draw-png (make-position 0 0) background-png))
    
    ; Funktion som skapar ett rgb-objekt
    (define/private (make-colour r g b)
      (make-object color% r g b))
    
    ; Ritar upp en maskerad bild
    (define/private (draw-masked-png position png mask)
      (let ((draw-position (translate-position position)))
        (send dc draw-bitmap
              png
              (get-x-position draw-position)
              (get-y-position draw-position)
              'solid
              floor-colour
              mask)))
    
    ; Ritar upp en bild
    (define/private (draw-png position png)
      (let ((draw-position (translate-position position)))
        (send dc draw-bitmap
              png
              (get-x-position draw-position)
              (get-y-position draw-position))))
      
    ; Funktion som "översätter" en position ur board till en position på canvas
    (define/private (translate-position position)
      (make-position (* (get-x-position position) block-size)
                     (* (get-y-position position) block-size)))
    
    ; Skapar en ny gif och för in denna i listan över aktiva gifs
    ; (Associationslista med (position . gif%)
    (define/private (make-new-gif position gif-list style)
      (set! active-gifs (cons (cons position 
                                    (new gif%
                                         [gif-list gif-list]
                                         [delay gif-delay]
                                         [position (translate-position position)]
                                         [dc dc]
                                         [background floor-png]
                                         [style style]))
                              active-gifs)))
    
    ; Skapar en ny gif-animering som ligger ovanpå ett objekt
    (define/private (make-new-animation position gif-list object-png)
      (new gif%
           [gif-list gif-list]
           [delay 50]
           [position (translate-position position)]
           [dc dc]
           [background floor-png]
           [style 'once]
           [object object-png]))
    
    ; Kontroll för redan aktiv gif
    (define/private (check-active-gifs position)
      (define (help lst)
        (cond ((null? lst) #f)
              ((equal? position (car (car lst))) #t)
              (else (help (cdr lst)))))
      (help active-gifs))
        
    ; Uppdateringsfunktion
    (define/private (refresh)
      (define (iter-row row)
        
        (define (iter-col col)
          (if (= col map-width)
              (void)
              (let* ((position (make-position col row))
                     (floor-object (send *current-board* get-object position))
                     (object-on-floor (send floor-object get-object)))
                
                (if (eq? object-on-floor 'empty)
                  (let ((type (send floor-object get-type)))
                    (cond ((eq? type 'void)
                           (void))
                          ((eq? type 'floor)
                           (draw-png position floor-png))
                          ((eq? type 'wall)
                           (draw-png position wall-png))
                          ((eq? type 'goal)
                           (draw-png position goal-png))
                          (else (error "Invalid floor type:" type))))
                  
                  (let ((type (send object-on-floor get-type)))
                    (cond ((eq? type 'player)
                           (if (eq? (send floor-object get-type) 'floor)
                               (draw-png position floor-png)
                               (draw-png position goal-png))
                           (draw-masked-png position player-png player-mask))
                          ((eq? type 'block)
                           (draw-png position block-png))
                          ((eq? type 'power-up)
                           (if (check-active-gifs position)
                               (void)
                               (make-new-gif position star-list 'continuous)))
                          (else (error "Invalid floor-object-type:" type)))))
                
                (iter-col (+ col 1)))))
        
        (if (= row map-height)
            (void)
            (begin
              (iter-col 0)
              (iter-row (+ row 1)))))
      
      (iter-row 0))
                          
    
    ; #### Public ####
    
    ; Omritningsfunktion, kallas i samband med nivåbyte.
    (define/public (redraw)
      (set! refresh? #t)
      (set! map-width (send *current-board* get-width))
      (set! map-height (send *current-board* get-height))
      (stop-all-animations)
      (draw))
    
    ; Den publika ritfunktionen
    (define/public (draw)
      (if refresh?
          (begin
            (fill-canvas)
            (set! refresh? #f)
            (refresh))
          (refresh)))
    
    ; Avslutar animationen på en specifik koordinat
    ; tar även bort detta element ur listan
    (define/public (stop-animation position)
      (define (help lst)
        (cond ((null? lst) '())
              ((equal? position (car (car lst)))
               (send (cdr (car lst)) stop-animation)
               (cdr lst))
              (else (cons (car lst) (help (cdr lst))))))
      (set! active-gifs (help active-gifs)))
    
    ; Lås eller aktivera inputmöjligheter till canvas
    (define/public (enable bool)
      (send canvas enable bool))
    
    ; Avsluta alla animeringar i active-gifs
    ; rensar även active-gifs
    (define/public (stop-all-animations)
      (define (help lst)
        (if (null? lst)
            (void)
            (begin
              (send (cdr (car lst)) stop-animation)
              (help (cdr lst)))))
      (help active-gifs)
      (set! active-gifs '()))
    
    ; Sätt fokus till canvas
    (define/public (focus)
      (send canvas focus))
    
    (define/public (get-width)
      canvas-width)
    
    ; Kör en animation som ligger "ovanpå" spelaren.
    (define/public (run-animation position identifier)
      (cond ((eq? identifier 'blink)
             (make-new-animation position blink-list player-png))
            (else (error "Unknown gif identifier:" identifier))))
    
    (super-new)))