////////////////////////////////////////
//dead_tomb f18a graphics loading

void full_screen_bitmap_palleted_picture_f18a_001(void);  //11
void crawl_right_fullscreen(void);
void init_vdp_flying_ship_f18a (void);
void flying_ship_screen(void);
void language_screen(void);
void aklaim_screen(void);
void hide_sprites(void);
void room_001_screen(void);
void room_002_screen(void);

void inventory_screen_init(void);
void map_screen_init(void);

//room_routines
void room_001_routine(void);
void room_002_routine(void);

void inventory_routine(void);
void map_routine(void);

//reuseable animaions routines
void animate_torches(void);
void player_input(void);
void input_text_routine(void);
byte check_walkable(byte local_x,byte local_y);
void player_animate(void);

void bounce_animate_sand(void);
void animate_sand(byte sand_frame);
void crawling_guy(void);

//text related routines
void blank_text_area(void);
void default_text(void);
void text_module(void);
void print_message(byte which_item_message);
byte print_list_of_things(byte which_things,byte item_number);
void waiting_unfire(void);

//animate_sand(0);
//ay-3-8910
void ay38910_main(void);
void play_test_song(void);

//f18a related
inline void VDP_SAFE_DELAY();
inline void VDP_SET_ADDRESS(unsigned int x);
void load_palette(const byte *pal, unsigned char count);

#define BLOCK_NMI  { __asm__("\tpush hl\n\tld hl,#_no_nmi\n\tset 0,(hl)\n\tpop hl"); }
#define RELEASE_NMI { __asm__("\tpush hl\n\tld hl,#_no_nmi\n\tbit 7,(hl)\n\tjp z,.+6\n\tcall _nmi_direct\n\tres 0,(hl)\n\tpop hl"); }


////////f18a freindly///////////////
/* VDP table addresses */
#define chrtab  0x1800
#define chrgen  0x0000

//f18a colour only requires 1/3 the colour data? til 0x2800
#define coltab  0x2000
#define sprtab_f18a  0x2800 //sprite location f18a
#define sprtab_f18a_002  0x3000 //sprite location f18a
#define sprtab_f18a_003  0x3800 //sprite location f18a


#define sprtab  0x3800 //sprite location standard
#define sprgen  0x1b00
#define mapvram 0x1f00  //256 bytes for extra ram

#define name_table1 0x1800
#define name_table2 0x1c00
