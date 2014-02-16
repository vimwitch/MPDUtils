CC=gcc
SOURCES=main.m mpd_song_list.m
EXECUTABLE=MPDUtils
CFLAGS=-Wall -std=c99 
LDFLAGS=-framework Foundation -L/usr/local/Cellar/libmpdclient/2.7/lib/ -lmpdclient -lobjc

all: $(EXECUTABLE)

$(EXECUTABLE) : $(SOURCES)
	 $(CC) -o $@ $(CFLAGS) $(SOURCES) $(LDFLAGS)

clean:
	rm $(EXECUTABLE)
