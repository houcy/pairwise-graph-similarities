
#ifndef UTILS_TIMER
#define UTILS_TIMER

#ifdef __cplusplus
extern "C" {
#endif

#include <time.h>

typedef struct my_timer_t_ {
  struct timespec start;
  struct timespec stop;
  long delta;
} * my_timer_t;

my_timer_t my_timer_build();

void my_timer_start(my_timer_t timer);
void my_timer_stop (my_timer_t timer);
void my_timer_delta(my_timer_t timer);

#ifdef __cplusplus
}
#endif

#endif

