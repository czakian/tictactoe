;;christopher zakian | czakian
;;hw2 part 1 -- just get the board working
;;I discussed the assignment with Karissa and gavin

(include "tictactoe.ss")
(import tic-tac-toe)
;;don't print gobbly-gook from the record types
(print-gensym #f)
;;copied from tictactoe.ss
(define compass-moves '(nw n ne w c e sw s se))

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

;;takes a t3g game and returns a symbols, which represents
;;the player whose turn it is
(define get-current-player
  (lambda (brd)
    (let ([history (game-history brd)])
      (cond
        [(null? history) (game-p1 brd)]
        [(null? (cdr history)) (game-p2 brd)]
        [else (caadr history)]))))

;;this just iterates through the game and selects the first empty space
(define bad-AI
  (lambda (board moves)
    (cond
      [(null? moves) #f]
      [(t3g-cell-empty? board (car moves)) (car moves)]
      [else (bad-AI board (cdr moves))])))

;;executes the move given by bad-AI.
;;this disconnection lets us run bad-AI in the main loop
;;to get the next move, and the only execute in it this function
(define make-tictactoe-player
  (lambda()
    (lambda (board)
      (t3g-move board (get-current-player board) (bad-AI board compass-moves)))))

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
         `(,board . 0)]
        [(win-exists? board)
         (printf "GAME OVER\n")
         (print-board board)
         `(,board . ,last-move)]
        [else
         (printf "move made at: ~s\n" (bad-AI board compass-moves))
         (print-board board)
         (newline)
         (if (eq? 'X  last-move)
             (loop (p2 board) board (get-current-player board))
             (loop (p1 board) board (get-current-player board)))]))))

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
