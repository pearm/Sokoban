;=====================================================
; PRAM 2011, Senast ändrad 2011-03-30
; Projekt: Sokoban
; Mattias Fransson, Marcus Eriksson, grupp 4, Y1a
;
; Fil: player.scm
; Beskrivning: Definierar ADT:n Player
;=====================================================

; Klass
(define player%
  (class object%
    
    ; Konstruktorvariabler
    (init-field current-position
                current-board)
    
    ; Lokala fält
    (field (type 'player)
           (current-power-up 'empty); Är båda dessa nödvändiga eller ska en power-up enbart transformeras
           (current-power-up-procedure #f)) ; till en procedur som lagras hos spelaren?
    
    ; #### Private ####
    
    
    ; #### Public ####
    
    ; Getters
    (define/public (get-position)
      current-position)
    
    (define/public (get-type)
      type)
    
    ; Setters
    (define/public (set-power-up! power-up)
      (set! current-power-up power-up))
    
    (define/public (set-position! position)
      (set! current-position position))
    
    ; Funktioner
       
    ; Flyttar spelaren
    (define/public (move! direction)
      (send current-board move! this direction))
    
    ; Använder spelarens power-up
    (define/public (use-power-up)
      (
       ;... to be defined ...
       ))    
    
    (super-new)))