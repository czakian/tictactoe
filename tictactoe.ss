;;; TIC TAC TOE
;;;
;;; Library for Homework 1 and Scheme instruction:
;;; Scheme library for Tic Tac Toe.

;;; Copyright (c) 2011 Aaron W. Hsu <arcfide@sacrideo.us>
;;; 
;;; Permission to use, copy, modify, and distribute this software for
;;; any purpose with or without fee is hereby granted, provided that the
;;; above copyright notice and this permission notice appear in all
;;; copies.
;;; 
;;; THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL
;;; WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED
;;; WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE
;;; AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL
;;; DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA
;;; OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
;;; TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
;;; PERFORMANCE OF THIS SOFTWARE.
 
;; In this file we define a module called tic-tac-toe, which defines an
;; API for programming with a tic tac toe game. To use this module, you
;; first load the file tictactoe.ss into your Scheme system, either with
;; INCLUDE or with LOAD.
;;  
;;       (load "tictactoe.ss")
;;  
;; With this the module will not be available for use. To get access to
;; the data structures and files that are defined in this module, you
;; will need to import it.
;;  
;;       (import tic-tac-toe)
;;  
;; This will make the procedures described below available to you for
;; use. 
;;  
;; PUBLIC API DOCUMENTATION
;;  
;; This section defines all of the public elements that are exported from
;; the TIC-TAC-TOE module. This will serve as documentation on what
;; functions are available to you, and what you can do with them. It will
;; not discuss the actual implementation of the library or give you any
;; tutorial or examples of writing Scheme code. For that, read the
;; developer documentation further down.
;;  
;; * Data Structures
;;  
;; Two data structures are defined by the TIC-TAC-TOE module. The first 
;; is a generic GAME type, which represents and encodes a two player
;; game. It allows you to track the history of the game as well as to
;; identify who is playing the game.
;;  
;; ** Game Type
;;  
;; The GAME type is very basic and very flexible. It defines the
;; following bindings:
;;  
;; Type: GAME
;;  
;; This is the type for GAME and may be used when defining sub-types of a
;; GAME.
;;  
;; Constructor: MAKE-GAME : P1 P2 => GAME
;; Constructor: MAKE-GAME : P1 P2 HISTORY => GAME
;; 
;; Constructs a new GAME, taking two symbols that represent the
;; identities of the two players in the game.
;; You can also provide a specific history list if you want to.
;;  
;; Predicate: GAME? : OBJ => BOOLEAN
;;  
;; When applies to any object, returns #t if that object is of type GAME
;; and #f otherwise.
;;  
;; Accessor: GAME-P1 : GAME => SYMBOL
;;  
;; When applied to a GAME object, it returns the symbol identifying the 
;; first player of the game.
;;  
;; Accessor: GAME-P2 : GAME => SYMBOL
;;  
;; When applied to a GAME object, it returns the symbol identifying the
;; second player of the game.
;;  
;; Accessor: GAME-HISTORY : GAME => LIST
;;  
;; When applied to a GAME object, it returns the list of moves in reverse
;; order that they were played. That is, the first element of the list is
;; the last move that was played. The encoding and type of every move is
;; up to the user of the GAME type.
;;  
;; Mutator: GAME-HISTORY-SET! : GAME LIST => #<VOID>
;;  
;; Takes a GAME object and a LIST of moves and mutates the history field
;; of the provided GAME object, setting it to the given LIST object.
;;  
;; ** Tic Tac Toe Game Type
;;  
;; WE also define a type T3G that is a sub-type of GAME. It represents a
;; tic tac toe game. 
;;  
;; Type: T3G
;;  
;; This is the type descriptor of the tic tac toe game type. You may use
;; it to syb-type new and different sorts of tic tac toe games.
;;  
;; Constructor: MAKE-T3G : P1 P2 => T3G
;; Constructor: MAKE-T3G : P1 P2 HISTORY BOARD => T3G
;;  
;; There are two different signatures for the MAKE-T3G constructor. The
;; first takes only the two players in the game and fills in the other
;; fields with appropriate empty fields. This is suitable when creating a
;; new game. The second instance accepts two additional arguments: a
;; history and a game board. The game board is a vector containing the
;; the board, and should be suitable for indexing into using the tic tac
;; toe location indexer. 
;;  
;; The history should be a valid history as defined by the GAME type. 
;;  
;; The second signature of MAKE-T3G is suitable for creating copies or
;; new games that are partially complete or have already been filled in
;; with certain elements.
;;  
;; Predicate: T3G? : OBJ => BOOLEAN
;;  
;; Return #t if and only if the OBJ is of type T3G, and #f otherwise.
;;  
;; Accessor: T3G-BOARD : T3G => VECTOR
;;  
;; Returns the vector representing the game board.
;;  
;; * Procedures
;; 
;; The following sections define procedures that are useful for operating
;; on the data types specified above. They should be used whenever
;; possible rather than operating on the data type elements themselves.
;;  
;; ** Game oriented
;; 
;; Procedure: GAME-HISTORY-ADD! : GAME MOVE => #<VOID>
;;  
;; Adds a new MOVE to the GAME.
;;  
;; ** Tic Tac Toe oriented
;; 
;; Procedure: T3G-MOVE : T3G PLAYER MOVE => T3G
;;  
;; This is a functional procedure that will create a new copy of T3G with
;; the additions of a new move being played.
;;  
;; Procedure: T3G-MOVE! : T3G PLAYER MOVE => #<VOID>
;;  
;; This side-effecting procedure will mutate the T3G object to play a new
;; move for player.
;;  
;; Procedure: T3G-CLEAR-BOARD! : T3G => #<VOID>
;;  
;; This will clear out a board to start from scratch.
;;  
;; Procedure: T3G-GET-CELL : T3G LOCATION => PLAYER 
;;  
;; This will return the value of the cell at LOCATION, which will be a
;; PLAYER. 
;; 
;; Procedure: T3G-CELL-EMPTY? : T3G LOCATION => BOOLEAN
;; 
;; This procedure indicates whether or not the given LOCATION is empty on
;; the board T3G provided.
;;  
;; Procedure: T3G-COPY : T3G => T3G
;;  
;; Creates a copy of the given T3G.
 
;; DEVELOPER DOCUMENTATION
;;  
;; This is the developer documentation. It will go piece by piece through
;; the code and talk about every procedure, implementation strategies,
;; and other notes. Please see above if you just want to see how to
;; use this module. If you want to learn how to write Scheme, or are just
;; interested in seeing the underlying code, this is for you.
;;  
;; 
;; This entire program is encapsulated into a module form, so we will
;; define that first. The module identifier is TIC-TAC-TOE and we export
;; all of the procedures and syntax that we defined above. We will also
;; make sure that we import (chezscheme) to ensure that we have all of
;; the expected libraries. We will use IMPORT-ONLY to make sure that we
;; have a clean environment that doesn't include any other procedures
;; that we might not expect to be around.
 
(module tic-tac-toe
  (game game? make-game game-p1 game-p2 game-history game-history-set!
   t3g t3g? make-t3g t3g-board
   game-history-add!
   t3g-move t3g-move! t3g-clear-board! get-t3g-cell t3g-cell-empty?
   t3g-copy)
  (import-only (chezscheme))

;; Next we want to define our set of moves. We have two different types
;; of moves that we want to be able to make in tic tac toe. We have moves
;; that are based on the compass coordinates, and moves based on the grid
;; coordinates. 
;;  
;; The compass coordinates map the following symbols to locations on the
;; board: 
;;  
;;   nw | n | ne 
;;  ----+---+----
;;    w | c | e
;;  ----+---+----
;;   sw | s | se
;;  
;; We want to map these onto our vector, which has the layout as follows:
;;  
;;    0 | 1 | 2 
;;   ---+---+---
;;    3 | 4 | 5
;;   ---+---+---
;;    6 | 7 | 8
;;  
;; We will do this by creating an association list that maps these two
;; together and then our indexer for compass locations can simply combine
;; ASSQ with CDR.
 
(define compass-moves '(nw n ne w c e sw s se))
(define compass-moves-length (length compass-moves))
(define compass-moves-alst
  (map cons compass-moves (iota compass-moves-length)))
(define (valid-compass-loc? x)
  (and (memq x compass-moves) #t))
(define (compass-loc->index x)
  (cdr (assq x compass-moves-alst)))

;; For our grid moves, we have a slightly different mapping:
;;  
;;   -1, 1 | 0, 1 | 1, 1
;;  -------+------+-------
;;   -1, 0 | 0, 0 | 1, 0
;;  -------+------+-------
;;   -1,-1 | 0,-1 | 1,-1
;;  
;; We will use the exact same technique as above, except that we compare
;; with ASSOC and MEMBER instead of ASSQ and MEMQ.

(define grid-moves
  '((-1 1) (0 1) (1 1)
    (-1 0) (0 0) (1 0)
    (-1 -1) (0 -1) (1 -1)))
(define grid-moves-length (length grid-moves))
(define grid-moves-alst
  (map cons grid-moves (iota grid-moves-length)))
(define (valid-grid-loc? x)
  (and (member x grid-moves) #t))
(define (grid-loc->index x)
  (cdr (assoc x grid-moves-alst)))

;; We probably also want to be able to tell whether a location is valid
;; in either form. So, we should combine both of our location predicates
;; into a more generic one.
 
(define (valid-loc? x)
  (or (valid-compass-loc? x) (valid-grid-loc? x)))

;; Next we will need a general indexer that can handle either location
;; type. This will also throw an error if we don't receive the right
;; thing.
 
(define (location->index x)
  (cond
    [(valid-compass-loc? x) (compass-loc->index x)]
    [(valid-grid-loc? x) (grid-loc->index x)]
    [else (error 'location->index "Invalid location" x)]))
 
;; Let's now take a moment to define our data types. Recall that we have
;; two, and that the T3G type is a sub-type of GAME. 
 
(define-record-type game 
  (fields p1 p2 (mutable history))
  (protocol
    (lambda (n)
      (case-lambda
        [(p1 p2) (n p1 p2 '())]
        [(p1 p2 h) (n p1 p2 h)]))))

(define-record-type t3g
  (fields board)
  (parent game)
  (protocol
    (lambda (p)
      (case-lambda
        [(p1 p2)
         ((p p1 p2) (make-vector 9 '()))]
        [(p1 p2 h b)
         ((p p1 p2 h) b)]))))

;; Let's now move on to the game procedures that we mentioned above.
;; Right now, the only one is GAME-HISTORY-ADD!.

(define (game-history-add! brd move)
  (assert (game? brd))
  (game-history-set! brd
    (cons move (game-history brd))))

;; Next we can move on to the procedures for actually playing
;; tic-tac-toe. The first is GET-T3G-CELL which lets us get the value of
;; any one element in the board. To implement this one, we want to just
;; convert the location that we receive to an index and retreive the
;; value straight from the vector that represents the board without any
;; conversion. That makes this one really simple.

(define (get-t3g-cell brd loc)
  (assert (t3g? brd))
  (assert (valid-loc? loc))
  (vector-ref (t3g-board brd) (location->index loc)))

;; It is helpful to be able to tell whether or not a given cell is empty.
;; To do this, we will just check whether our cell contains the empty
;; element.
 
(define (t3g-cell-empty? brd loc)
  (assert (t3g? brd))
  (assert (valid-loc? loc))
  (null? (get-t3g-cell brd loc)))

;; The next procedure is a basic mutator for making a move on the board.
;; There are two things we care about doing in this one. The first is
;; setting up the board to make the move, and the other is making sure
;; that we add that move to the history. We should make sure that the
;; move we want to make is empty before we move, for which we will use
;; the above defined T3G-CELL-EMPTY?.
 
(define (t3g-move! brd p m)
  (assert (t3g? brd))
  (assert (valid-loc? m))
  (assert (or (eq? p (game-p1 brd)) (eq? p (game-p2 brd))))
  (unless (t3g-cell-empty? brd m)
    (error 't3g-move! "Cell already occupied" brd m))
  (vector-set! (t3g-board brd) (location->index m) p)
  (game-history-add! brd (cons p m)))

;; If we want to create a copy of the board, we can do this using the
;; following procedure. It's pretty easy, we just have to use the long
;; form of the constructurs that we defined above.
 
(define (t3g-copy brd)
  (assert (t3g? brd))
  (let ([p1 (game-p1 brd)] [p2 (game-p2 brd)]
        [h  (game-history brd)]
        [b  (t3g-board brd)])
    (make-t3g p1 p2 h (vector-copy b))))
 
;; Implementing the functional version of T3G-MOVE! is pretty simple, but
;; only because we already have all the mutators. Basically, we want to
;; create a copy of the previous board and then mutate the elements.

(define (t3g-move brd p m)
  (assert (t3g? brd))
  (assert (valid-loc? m))
  (assert (or (eq? p (game-p1 brd)) (eq? p (game-p2 brd))))
  (let ([new (t3g-copy brd)])
    (t3g-move! new p m)
    new))

;; Finally, we want to be able to empty a board if we feel like it. This
;; is simply a matter of erasing the history and filling the board with
;; empty values.

(define (t3g-clear-board! brd)
  (assert (t3g? brd))
  (game-history-set! brd '())
  (vector-fill! (t3g-board brd) '()))

)
