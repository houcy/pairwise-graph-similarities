
#include "timer.h"

#include <stdlib.h>

my_timer_t my_timer_build() {
  return malloc(sizeof(struct my_timer_t_));
}

void my_timer_start(my_timer_t timer) {
   if (timer == NULL) return;

  clock_gettime(CLOCK_REALTIME, &(timer->start));
}

void my_timer_stop (my_timer_t timer) {
   if (timer == NULL) return;

  clock_gettime(CLOCK_REALTIME, &(timer->stop));
}

void my_timer_delta(my_timer_t timer) {
   if (timer == NULL) return;

  timer->delta = (timer->stop.tv_nsec - timer->start.tv_nsec) / 1000000;
  if (timer->delta > 0)
    timer->delta += (timer->stop.tv_sec - timer->start.tv_sec) * 1000;
  else
    timer->delta = (timer->stop.tv_sec - timer->start.tv_sec) * 1000 - timer->delta;
}

