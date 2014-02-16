//
//  main.m
//
//  Created by Chance Hudson on 2/7/14.
//  Copyright (c) 2014 Chance Hudson. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <mpd/client.h>
#include "mpd_song_list.h"

enum OutputFormat {
    OUTPUT_FORMAT_URI = 0,
    OUTPUT_FORMAT_NAME = 1,
	OUTPUT_FORMAT_DEFAULT = 2
};

struct mpd_song_list* search(struct mpd_connection* connection, enum mpd_tag_type type, const char *string);
bool strnicmp(const char *str1, const char *str2);
void print_song_list(struct mpd_song_list *list, enum OutputFormat format);

void print_usage(){
	printf("MPDTest -s search_term -t [title:album:artist:albumArtist] -o [uri:title] -a URI_to_add \n");
	printf("-s : search for string\n");
	printf("-t : search type, one of the following: title, album, artist, albumArtist\n");
	printf("-o : search result output format, either URI or name\n");
	printf("-a : add file to current playlist, accepts URI : -a can be specified multiple times to add multiple files\n");
}

int main(int argc, const char * argv[])
{
    @autoreleasepool {
		if(argc == 1){
			print_usage();
			exit(0);
		}
        struct mpd_connection *connection = mpd_connection_new("localhost", 0, 0);
        if(mpd_connection_get_error(connection) != MPD_ERROR_SUCCESS){
            NSLog(@"Error connecting: %s", mpd_connection_get_error_message(connection));
        }
        
        const char *searchString = NULL;
        enum OutputFormat format = OUTPUT_FORMAT_DEFAULT;
        enum mpd_tag_type *searchTypes = calloc(1, sizeof(enum mpd_tag_type));
		searchTypes[0] = MPD_TAG_TITLE;
		unsigned int searchTypeCount = 1;
        
        for(int x = 0; x < argc; x++){
            if(strnicmp(argv[x], "-a")){
                //add the file
				NSLog(@"MPDUtils %s", argv[++x]);
                mpd_send_add(connection, argv[x]);
            }
            else if(strnicmp(argv[x], "-s")){
				//search for the name
                searchString = argv[++x];
            }
            else if(strnicmp(argv[x], "-o")){
                const char *f = argv[++x];
                if(strnicmp(f, "uri")){
                    format = OUTPUT_FORMAT_URI;
                }
                else if (strnicmp(f, "title")){
                    format = OUTPUT_FORMAT_NAME;
                }
            }
            else if(strncmp(argv[x], "-t", 2) == 0 && strlen(argv[x]) >= 3){
				searchTypeCount = 0;
				for(int z = 2; z < strlen(argv[x]); z++){
					const char c = argv[x][z];
					if(c == 'a'){
						searchTypeCount++;
						searchTypes = realloc(searchTypes, sizeof(enum mpd_tag_type)*searchTypeCount);
						searchTypes[searchTypeCount-1] = MPD_TAG_ARTIST;
					}
					else if(c == 'A'){
						searchTypeCount++;
						searchTypes = realloc(searchTypes, sizeof(enum mpd_tag_type)*searchTypeCount);
						searchTypes[searchTypeCount-1] = MPD_TAG_ALBUM_ARTIST;
					}
					else if(c == 'T'){
						searchTypeCount++;
						searchTypes = realloc(searchTypes, sizeof(enum mpd_tag_type)*searchTypeCount);
						searchTypes[searchTypeCount-1] = MPD_TAG_TITLE;
					}
					else if(c == 'l'){
						searchTypeCount++;
						searchTypes = realloc(searchTypes, sizeof(enum mpd_tag_type)*searchTypeCount);
						searchTypes[searchTypeCount-1] = MPD_TAG_ALBUM;
					}
				}
				if(searchTypeCount == 0){
					// reset to the default search type
					searchTypeCount = 1;
					searchTypes = realloc(searchTypes, sizeof(enum mpd_tag_type));
					searchTypes[0] = MPD_TAG_TITLE;
				}
            }
        }
        
        if(searchString == NULL)
            exit(0);
		for(int x = 0; x < searchTypeCount; x++){
			struct mpd_song_list* list = search(connection, searchTypes[x], searchString);
			if(searchTypes[x] == MPD_TAG_TITLE){
				print_song_list(list, format);
			}
			else{
				struct mpd_tag_list *tagList = tag_list_from_song_list(list, searchTypes[x]);
				for(int z = 0; z < tagList->count; z++){
					printf("%s\n", tagList->tags[z]);
				}
			}
		}
        mpd_connection_free(connection);
    }
    return 0;
}

bool strnicmp(const char *str1, const char *str2) //case insensitive compare
{
    if(strlen(str1) != strlen(str2)) return false;
    for(int x = 0; x < strlen(str1); x++) if(tolower(str1[x]) != tolower(str2[x])) return false;
    return true;
}

void print_song_list(struct mpd_song_list *list, enum OutputFormat format){
	for(int x = 0; x < list->count; x++){
		const char *path = NULL;
		const char *name = NULL;
		path = mpd_song_get_uri(list->songs[x]);
		name = mpd_song_get_tag(list->songs[x], MPD_TAG_TITLE, 0);
		if(format == OUTPUT_FORMAT_DEFAULT)
			printf("%s|%s|%s\n", path, name, mpd_song_get_tag(list->songs[x], MPD_TAG_ALBUM_ARTIST, 0));
		else if(format == OUTPUT_FORMAT_NAME)
			printf("%s\n", name);
		else if(format == OUTPUT_FORMAT_URI)
			printf("%s\n", path);
	}
}

struct mpd_song_list* search(struct mpd_connection* connection, enum mpd_tag_type type, const char *string)
{
    mpd_search_db_songs(connection, false);
    mpd_search_add_tag_constraint(connection, MPD_OPERATOR_DEFAULT, type, string);
    mpd_search_commit(connection);
    struct mpd_song_list *list = malloc(sizeof(struct mpd_song_list));
    list->songs = NULL;
    list->count = 0;
    for(int x=0;;x++){
        struct mpd_song *temp = mpd_recv_song(connection);
        if(temp == NULL)
            break;
        if(x >= list->count){
            list->count++;
            list->songs = realloc(list->songs, sizeof(struct mpd_song*)*list->count);
        }
        list->songs[x] = temp;
    }
    return list;
}
