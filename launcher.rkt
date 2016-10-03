#lang racket/base

(require racket/string racket/system racket/list)

;; Program to hypervise bot threads
;; Step 1: create a vector of Bot threads
;; Step 2: check whether a thread has been finished or not
;; Step 3: if a thread is dead, re-activate the thread with the original bot
;; Step 4: sleep for a little bit before re-checking threads

;; Struct mapping for a Bot program
;; interp - the interpreter we want to use to execute a bot program
;; code   - the name of the file we want to execute with the interp
;; key    - a file containing the Discord tokens for each bot
(struct bot (interp code key))

;; Define bots here - file to execute and their keys
(define bots
  (vector
   (bot "python" "bots/dumb-bot.py"   "dumb-bot.key")
   (bot "python" "bots/remind-bot.py" "remind-bot.key")
   ))

;; Functions ################################################################
;; Convert a bot struct into an executable string
(define (bot->command bot)
  (string-join (list (bot-interp bot) (bot-code bot) (bot-key bot)) " "))

;; Turn a bot into a thread
(define (start-bot bot-id)
  (thread
   (λ ()
     (displayln (format "Starting bot ~a" bot-id))
     (system (bot->command (vector-ref bots bot-id)))
     (displayln (format "Bot ID ~a ended unexpectedly" bot-id)))))

;; The necromancer function to create new threads from dead matter 
(define (re-animate id)
  (displayln (format "Checking thread ~a" id))
  (when (thread-dead? (vector-ref threads id))
    (displayln (format "Bringing thread ~a back to life" id))
    (vector-set! threads id (start-bot id))))

;; Variables ###############################################################
;; Total number of bots we have to manage
(define total-bots (vector-length bots))

;; The bot threads to maintain
(define threads
  (build-vector total-bots start-bot))

;; Main loop and re-activation thread
(define main-t
  (thread
   (λ ()
     (define (loop)
       (displayln "Beginning Gravekeeper sweep...")
       (for ([x (in-range total-bots)])
         (re-animate x))
       (displayln "Sleeping Gravekeeper...")
       (sleep 60) ; number of seconds the gravekeeper should sleep
       (loop))
     (loop))))

(thread-wait main-t)