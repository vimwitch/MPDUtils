//
// mpd_song_list.m
//
// Created by Chance Hudson 2/15/14.
// Copyright (c) 2014 Chance Hudson. All rights reserved.
//

#include "mpd_song_list.h"

struct mpd_tag_list* tag_list_from_song_list(struct mpd_song_list *list, enum mpd_tag_type tag){
	struct mpd_tag_list *returnList = malloc(sizeof(struct mpd_tag_list));
	returnList->count = 0;
	returnList->tags = malloc(sizeof(const char *)*list->count);
	for(int x = 0; x < list->count; x++){
		if(list->songs[x] == NULL)
			continue;
		const char *t = mpd_song_get_tag(list->songs[x], tag, 0);
		if(tag_list_contains_string(returnList, t))
			continue;
		returnList->tags[returnList->count] = t;
		song_list_remove_songs(list, tag, returnList->tags[returnList->count]);
		returnList->count++;
	}
	returnList->tags = realloc(returnList->tags, sizeof(const char*)*returnList->count);
	return returnList;
}

bool tag_list_contains_string(struct mpd_tag_list *tagList, const char *string){
	for(int x = 0; x < tagList->count; x++){
		if(tagList->tags[x] == NULL)
			continue;
		if(strncmp(tagList->tags[x], string, strlen(string)) == 0)
			return true;
	}
	return false;
}

void song_list_remove_songs(struct mpd_song_list *list, enum mpd_tag_type tag_type, const char *tag){
	for(int x = 0; x < list->count; x++){
		if(list->songs[x] == NULL)
			continue;
		const char *tagVal = mpd_song_get_tag(list->songs[x], tag_type, 0);
		if(strncmp(tagVal, tag, strlen(tag)) == 0){
			list->songs[x] = NULL;
		}
	}
}

void mpd_song_list_remove_songs(struct mpd_song_list *list, const char *tag, enum mpd_tag_type tag_type){
	//remove songs with matching value for tag
	struct mpd_song_list *newList = malloc(sizeof(struct mpd_song_list));
	newList->count = 0;
	newList->songs = malloc(sizeof(struct mpd_song *)*list->count); //create a new array with size of original list - resize the array later after determining new size
	for(int x = 0; x < list->count; x++){
		const char *tagVal = mpd_song_get_tag(list->songs[x], tag_type, 0);
		if(strncmp(tagVal, tag, strlen(tag)) != 0){
			newList->count++;
			newList->songs[x] = list->songs[x];
		}
	}
	newList->songs = realloc(newList->songs, sizeof(struct mpd_song *)*newList->count);
	list->count = newList->count;
	free(list->songs);
	list->songs = newList->songs;
}
