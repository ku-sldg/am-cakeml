#ifndef __DEBUG_H__
#define __DEBUG_H__

// #define DEBUGPRINT 1

#ifdef DEBUGPRINT
#define DEBUG_PRINT(...) { fprintf( stderr, __VA_ARGS__ ); }
#else
#define DEBUG_PRINT(...) { (void)0; }
#endif

#endif
