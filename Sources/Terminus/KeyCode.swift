import Foundation
public enum KeyCode: Int32 {
    /* ASCII control characters */
    /// ASCII control c (^C)
    case KEY_CONTROL_C = 3
    /// ASCII BS
    case KEY_BS = 8
    /// ASCII tab (HT)
    case KEY_TAB = 9
    /// ASCII Line feed (LF)
    case KEY_LF = 10
    /// ASCII carriage return (CR)
    case KEY_CR = 13
    /// ASCII escape (ESC)
    case KEY_ESC = 27
    /// ASCII delete (DEL)
    case KEY_DEL = 127
    /* From ncurses */
    /// A wchar_t contains a key code
    case KEY_CODE_YES = 256 
    /// Minimum curses key
    case KEY_MIN = 257 
    /// Soft (partial) reset (unreliable)
    case KEY_SRESET = 344 
    /// Reset or hard reset (unreliable)
    case KEY_RESET = 345 
    /// down-arrow key
    case KEY_DOWN = 258 
    /// up-arrow key
    case KEY_UP = 259 
    /// left-arrow key
    case KEY_LEFT = 260 
    /// right-arrow key
    case KEY_RIGHT = 261 
    /// home key
    case KEY_HOME = 262 
    /// backspace key
    case KEY_BACKSPACE = 263 
    /// Function keys. Space for 64
    case KEY_F0 = 264 
    /// F1 key
    case KEY_F1 = 265
    /// F2 key
    case KEY_F2 = 266
    /// F3 key
    case KEY_F3 = 267
    /// F4 key
    case KEY_F4 = 268
    /// F5 key
    case KEY_F5 = 269
    /// F6 key
    case KEY_F6 = 270
    /// F7 key
    case KEY_F7 = 271
    /// F8 key
    case KEY_F8 = 272
    /// F9 key
    case KEY_F9 = 273
    /// F10 key
    case KEY_F10 = 274
    /// F11 key
    case KEY_F11 = 275
    /// F12 key
    case KEY_F12 = 276
    /// delete-line key
    case KEY_DL = 328 
    /// insert-line key
    case KEY_IL = 329 
    /// delete-character key
    case KEY_DC = 330 
    /// insert-character key
    case KEY_IC = 331 
    /// sent by rmir or smir in insert mode
    case KEY_EIC = 332 
    /// clear-screen or erase key
    case KEY_CLEAR = 333 
    /// clear-to-end-of-screen key
    case KEY_EOS = 334 
    /// clear-to-end-of-line key
    case KEY_EOL = 335 
    /// scroll-forward key
    case KEY_SF = 336 
    /// scroll-backward key
    case KEY_SR = 337 
    /// next-page key
    case KEY_NPAGE = 338 
    /// previous-page key
    case KEY_PPAGE = 339 
    /// set-tab key
    case KEY_STAB = 340 
    /// clear-tab key
    case KEY_CTAB = 341 
    /// clear-all-tabs key
    case KEY_CATAB = 342 
    /// enter/send key
    case KEY_ENTER = 343 
    /// print key
    case KEY_PRINT = 346 
    /// lower-left key (home down)
    case KEY_LL = 347 
    /// upper left of keypad
    case KEY_A1 = 348 
    /// upper right of keypad
    case KEY_A3 = 349 
    /// center of keypad
    case KEY_B2 = 350 
    /// lower left of keypad
    case KEY_C1 = 351 
    /// lower right of keypad
    case KEY_C3 = 352 
    /// back-tab key
    case KEY_BTAB = 353 
    /// begin key
    case KEY_BEG = 354 
    /// cancel key
    case KEY_CANCEL = 355 
    /// close key
    case KEY_CLOSE = 356 
    /// command key
    case KEY_COMMAND = 357 
    /// copy key
    case KEY_COPY = 358 
    /// create key
    case KEY_CREATE = 359 
    /// end key
    case KEY_END = 360 
    /// exit key
    case KEY_EXIT = 361 
    /// find key
    case KEY_FIND = 362 
    /// help key
    case KEY_HELP = 363 
    /// mark key
    case KEY_MARK = 364 
    /// message key
    case KEY_MESSAGE = 365 
    /// move key
    case KEY_MOVE = 366 
    /// next key
    case KEY_NEXT = 367 
    /// open key
    case KEY_OPEN = 368 
    /// options key
    case KEY_OPTIONS = 369 
    /// previous key
    case KEY_PREVIOUS = 370 
    /// redo key
    case KEY_REDO = 371 
    /// reference key
    case KEY_REFERENCE = 372 
    /// refresh key
    case KEY_REFRESH = 373 
    /// replace key
    case KEY_REPLACE = 374 
    /// restart key
    case KEY_RESTART = 375 
    /// resume key
    case KEY_RESUME = 376 
    /// save key
    case KEY_SAVE = 377 
    /// shifted begin key
    case KEY_SBEG = 378 
    /// shifted cancel key
    case KEY_SCANCEL = 379 
    /// shifted command key
    case KEY_SCOMMAND = 380 
    /// shifted copy key
    case KEY_SCOPY = 381 
    /// shifted create key
    case KEY_SCREATE = 382 
    /// shifted delete-character key
    case KEY_SDC = 383 
    /// shifted delete-line key
    case KEY_SDL = 384 
    /// select key
    case KEY_SELECT = 385 
    /// shifted end key
    case KEY_SEND = 386 
    /// shifted clear-to-end-of-line key
    case KEY_SEOL = 387 
    /// shifted exit key
    case KEY_SEXIT = 388 
    /// shifted find key
    case KEY_SFIND = 389 
    /// shifted help key
    case KEY_SHELP = 390 
    /// shifted home key
    case KEY_SHOME = 391 
    /// shifted insert-character key
    case KEY_SIC = 392 
    /// shifted left-arrow key
    case KEY_SLEFT = 393 
    /// shifted message key
    case KEY_SMESSAGE = 394 
    /// shifted move key
    case KEY_SMOVE = 395 
    /// shifted next key
    case KEY_SNEXT = 396 
    /// shifted options key
    case KEY_SOPTIONS = 397 
    /// shifted previous key
    case KEY_SPREVIOUS = 398 
    /// shifted print key
    case KEY_SPRINT = 399 
    /// shifted redo key
    case KEY_SREDO = 400 
    /// shifted replace key
    case KEY_SREPLACE = 401 
    /// shifted right-arrow key
    case KEY_SRIGHT = 402 
    /// shifted resume key
    case KEY_SRSUME = 403 
    /// shifted save key
    case KEY_SSAVE = 404 
    /// shifted suspend key
    case KEY_SSUSPEND = 405 
    /// shifted undo key
    case KEY_SUNDO = 406 
    /// suspend key
    case KEY_SUSPEND = 407 
    /// undo key
    case KEY_UNDO = 408 
    /// Mouse event has occurred
    case KEY_MOUSE = 409 
    /// Terminal resize event
    case KEY_RESIZE = 410 
}
