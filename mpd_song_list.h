//
// mpd_song_list.h
//
// Created by Chance Hudson 2/15/14.
// Copyright (c) 2014 Chance Hudson. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <stdlib.h>
#include <string.h>
#include <mpd/client.h>

struct mpd_song_list {
	struct mpd_song **songs;
	unsigned count;
};

struct mpd_tag_list {
	enum mpd_tag_type tag_type;
	const char **tags;
	unsigned count;
};

struct mpd_tag_list* tag_list_from_song_list(struct mpd_song_list *list, enum mpd_tag_type tag);
bool tag_list_contains_string(struct mpd_tag_list *tagList, const char *string);
void song_list_remove_songs(struct mpd_song_list *list, enum mpd_tag_type tag_type, const char *tag);
void mpd_song_list_remove_songs(struct mpd_song_list *list, const char *tag, enum mpd_tag_type tag_type);
