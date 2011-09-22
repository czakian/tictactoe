;;christopher zakian | czakian
;;hw2 part 1 -- just get the board working
;;I discussed the assignment with Karissa and gavin

(include "tictactoe.ss")
(import tic-tac-toe)
;;don't print gobbly-gook from the record types
(print-gensym #f)
;;all the possible paths
(define paths '((nw w sw) (n c s) (ne e se) (nw n ne) (w c e) (sw s se) (nw c se) (ne c sw)))
;;copied over from Aaron's code
(define compass-moves '(nw n ne w c e sw s se))
(define (valid-compass-loc? x)
  (and (memq x compass-moves) #t))

;;takes a t3g game.
;;returns #t if 3 consecutive Xs or Os appear on the board.
;;returns #f otherwise
(define win-exists?
  (lambda (board)
    (let ([cols '((nw w sw) (n c s) (ne e se))]
          [rows '((nw n ne) (w c e) (sw s se))]
          [diag '((nw c se) (ne c sw))])
      (or (has-chance? board cols) (has-chance? board rows) (has-chance? board diag)))))

;;helper function for win-exists?
;;we are folding over the list with the arguments from
;;win-exists, and then folding over each inner list.
;;we know that a win exists when the count of consecutive
;;symbols is 2 since I am using a zero index.
(define has-chance?
  (lambda (board ls)
    (call/cc
     (lambda (break)
       ;;fold over the list of arguments
       ;;structure used is a boolean, and is what is returned to win-exists?
       (fold-right
        (lambda (subls path)
          (if (<= 2
                  ;;cdr will be an integer because
                  ;;this fold right is using this structure: (symbol . count)
                  (cdr
                   (fold-right
                    (lambda (x unit)
                      (cond
                        [(and
                          (equal? (get-t3g-cell board x) (car unit))
                          (not (null? (car unit))))
                         `( ,(car unit) . ,(add1 (cdr unit)))]
                        [else
                         `(,(get-t3g-cell board x) . -1)]))
                    `(, (get-t3g-cell board (car subls)) . 0)
                    (cdr subls))))

              (break #t) ;;evaluates when the if above is true
              #f)) ;;evaluates when the if above is false
        #f
        ls)))))

;;takes a t3g game and returns a symbol, which represents
;;the player whose turn it is
(define get-cur-player
  (lambda (brd)
    (let ([history (game-history brd)])
      (cond
        [(null? history) (game-p1 brd)]
        [(null? (cdr history)) (game-p2 brd)]
        [else (caadr history)]))))

;;takes a t3g game and returns a symbol, which represents
;;the player who just went
(define get-non-current-player
  (lambda (brd)
    (let ([history (game-history brd)])
      (cond
        [(null? history) (game-p2 brd)]
        [(null? (cdr history)) (game-p1 brd)]
        [else (caar history)]))))

;;takes a t3g game and returns a move or #f.
;;chooses which move to play in the t3g game.
(define select-move
  (lambda (board)
    ;;the inverse applies when checking for moves that we must do,
    ;;such as when p1 must defend, p1 can win, so we can run
    ;;defend twice with different players.
    (let ([defense (defend board paths (get-non-current-player board))]
          [offense (defend board paths (get-cur-player board))])
      (cond
        [(car offense) (cdr offence)]
        [(car defense) (cdr defense)]
        [else (if(valid-compass-loc? (pick-sensible-move board))
                 (pick-sensible-move board)
                 #f)]))))

;;takes a list of lists (all the paths possible in a t3g game)
;;and returns a dotted pair of a boolean and a value.
;;this checks to see if a win is for the opposite player is
;;imminent on the next move. This can also see if the current player
;;will win on the next move.
(define defend
  (lambda (board ls player)
    (cond
      [(null? ls) `( #f . _)]
      [(= 2 (traverse board (car ls) player))
       (let ([open (snag-empty board (car ls))])
         (cond
           [(null? open) (defend board (cdr ls) player)]
           [else `(#t . ,open)]))]
      [else (defend board (cdr ls) player)])))

;;used by defend to get the empty cell in a path
;;that has 2 spaces filled already
(define snag-empty
  (lambda (board ls)
    (cond
      [(null? ls) ls]
      [(null? (get-t3g-cell board (car ls))) (car ls)]
      [else (snag-empty board (cdr ls))])))

;;used by defend to determine if a board has 2
;;spaces filled by a single player on a given path
(define traverse
  (lambda (board ls player)
    (cond
      [(null? ls) 0]
      [(equal? (get-t3g-cell board (car ls)) player)
       (+ 1 (traverse board (cdr ls) player))]
      [else (traverse board (cdr ls) player)])))

;;give back the move that gives us the most paths
;;leading from the move.
(define pick-sensible-move
  (lambda (board)
    (cond
      [(null? (get-t3g-cell board 'c)) 'c]
      [(null? (get-t3g-cell board 'nw)) 'nw]
      [(null? (get-t3g-cell board 'ne)) 'ne]
      [(null? (get-t3g-cell board 'se)) 'se]
      [(null? (get-t3g-cell board 'sw)) 'sw]
      [(null? (get-t3g-cell board 'n)) 'n]
      [(null? (get-t3g-cell board 'w)) 'w]
      [(null? (get-t3g-cell board 'e)) 'e]
      [(null? (get-t3g-cell board 's)) 's])))

(define make-tictactoe-player
  (lambda()
    (lambda (board)
      (let ([move (select-move board)])
        (if move
            (t3g-move board (get-cur-player board) move)
            #f)))))

;;main loop for the game
;;takes two instances of make-tictactoe-player.
;;returns a pair of the final board and either the symbol of the winning player,
;;or 0 if the game is a tie
(define play-tictactoe
  (lambda (p1 p2)
    (let loop ([board (make-t3g 'X 'O)]
               [prev-board 'nil]
               [last-move 'nil])
      (cond
        [(not board)
         (printf "GAME OVER\n")
         (print-board prev-board)
         `(,prev-board . 0)]
        [(win-exists? board)
         (printf "GAME OVER\n")
         (print-board board)
         `(,board . ,last-move)]
        [else
         (printf "move made at: ~s\n" (select-move board))
         (print-board board)
         (newline)
         (if (eq? 'X  last-move)
             (loop (p2 board) board (get-cur-player board))
             (loop (p1 board) board (get-cur-player board)))]))))

;;utility function to make the board display nicer
(define swap-null
  (lambda (p)
    (if (null? p)
        '-
        p)))

(define print-board
  (lambda (board)
    (printf " ~s | ~s | ~s \n"
            (swap-null (get-t3g-cell board 'nw))
            (swap-null (get-t3g-cell board 'n))
            (swap-null (get-t3g-cell board 'ne)))
    (printf "-----------\n")
    (printf " ~s | ~s | ~s \n"
            (swap-null (get-t3g-cell board 'w))
            (swap-null (get-t3g-cell board 'c))
            (swap-null (get-t3g-cell board 'e)))
    (printf "-----------\n")
    (printf " ~s | ~s | ~s \n"
            (swap-null (get-t3g-cell board 'sw))
            (swap-null (get-t3g-cell board 's))
            (swap-null (get-t3g-cell board 'se)))))

