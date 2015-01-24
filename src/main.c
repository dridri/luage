#include <locale.h>
#include <ctype.h>
#include <libge/libge.h>
#include <lua5.2/lauxlib.h>

#include "c30log.h"
#include "gelua.h"
#include "ui.Button.h"
#include "ui.InputText.h"
#include "Page.h"
#include "BigMenu.h"
#include "Menu.h"

#define DECL_RC_BLOB(n) \
	extern char _binary_##n##_lua_start; \
	extern char _binary_##n##_lua_end;

#define RC_BLOB_START(n) &_binary_##n##_lua_start
	
#define RC_BLOB_END(n) &_binary_##n##_lua_end

#define min(a, b) ( ((a) < (b)) ? (a) : (b) )

ge_Font* font = 0;

DECL_RC_BLOB(c30log);
DECL_RC_BLOB(ge);
DECL_RC_BLOB(ui_Button);
DECL_RC_BLOB(ui_InputText);
DECL_RC_BLOB(Page);
DECL_RC_BLOB(BigMenu);
DECL_RC_BLOB(Menu);

char* mkrcstring(char* start, char* end){
	static char* str = 0;
	if(str == 0){
		str = (char*)geMalloc(16384);
	}
	memcpy(str, start, end - start);
	str[end - start] = 0;
	return str;
}

void getGameInfos(ge_LuaScript* script, int* exit, char* currPage)
{
	geLuaTableOpen(script, "screen", true);
	*exit = geLuaTableVariableIntegerByName(script, "exit");
	const char* spage = geLuaTableVariableStringByName(script, "spage");
	geLuaTableClose(script);

	if(strcmp(currPage, spage)){
		if(currPage[0]){
			char tmp[128];
			sprintf(tmp, "%s:lostfocus", currPage);
			geLuaCallFunction(script, tmp, "");
		}
		geLuaCallFunction(script, "screen.page:baseinit", "");
		strcpy(currPage, spage);
	}
}

int main(int ac, char** av)
{
	if(ac > 1 && !strcmp(av[1], "--debug")){
		geDebugMode(GE_DEBUG_ALL);
	}
	geInit();
	geSplashscreenEnable(false);
	ge_Keys* keys = geCreateKeys();

	char locale[32] = "";
	setlocale(LC_ALL, "");
	char* flocale = setlocale(LC_ALL, NULL);
	if(flocale){
		strcpy(locale, flocale);
		for(char* p=locale; *p; ++p) *p = tolower(*p);
		if(strchr(locale, '_')){
			strchr(locale, '_')[0] = 0;
		}
		if(strchr(locale, '.')){
			strchr(locale, '.')[0] = 0;
		}
	}
	if(!locale[0]){
		strcpy(locale, "en");
	}
	gePrintDebug(0x100, "locale : %s\n", locale);


	char locale_lua[64] = "";
	sprintf(locale_lua, "languages/%s.lua", locale);
	if(!geFileExists(locale_lua)){
		strcpy(locale, "en");
	}
	sprintf(locale_lua, "languages/%s.lua", locale);

	ge_LuaScript* script = geLoadLuaScript("config.lua");

	geLuaDoString(script, "MOBILE = 1\n");
	geLuaDoString(script, "DESKTOP = 2\n");
	geLuaDoString(script, "screen = {}\n");
	geLuaDoString(script, "platform = {}\n");
#if (defined(PLATFORM_android) || defined(PLATFORM_ios))
	geLuaDoString(script, "platform.type = MOBILE\n");
#else
	geLuaDoString(script, "platform.type = DESKTOP\n");
#endif
	geLuaScriptStart(script, GE_LUA_EXECUTION_MODE_NORMAL);

#ifdef PLATFORM_android
	geCreateMainWindow("", -1, -1, 0);
	geCursorVisible(false);
#else
	geCreateMainWindow("GE", 400, 640, GE_WINDOW_RESIZABLE);
#endif
	geWaitVsync(true);
	geClearColor(RGBA(0, 0, 0, 255));
/*
	geLuaDoString(script, mkrcstring(RC_BLOB_START(c30log), RC_BLOB_END(c30log)));
	geLuaDoString(script, mkrcstring(RC_BLOB_START(ge), RC_BLOB_END(ge)));
	geLuaDoString(script, mkrcstring(RC_BLOB_START(ui_Button), RC_BLOB_END(ui_Button)));
	geLuaDoString(script, mkrcstring(RC_BLOB_START(ui_InputText), RC_BLOB_END(ui_InputText)));
	geLuaDoString(script, mkrcstring(RC_BLOB_START(Page), RC_BLOB_END(Page)));
	geLuaDoString(script, mkrcstring(RC_BLOB_START(BigMenu), RC_BLOB_END(BigMenu)));
	geLuaDoString(script, mkrcstring(RC_BLOB_START(Menu), RC_BLOB_END(Menu)));
*/
	printf("h_c30log :\n%s\n", h_c30log);
	geLuaDoString(script, h_c30log);
	geLuaDoString(script, h_gelua);
	geLuaDoString(script, h_uiButton);
	geLuaDoString(script, h_uiInputText);
	geLuaDoString(script, h_Page);
	geLuaDoString(script, h_BigMenu);
	geLuaDoString(script, h_Menu);

	gePrintDebug(0, "A \n");
	geLuaDoFile(script, "index.lua");
	gePrintDebug(0, "B \n");

	if(geFileExists(locale_lua)){
		geLuaCallFunction(script, "screen.setLocale", "s", locale);
	}
	geLuaCallFunction(script, "screen.init", "i, i", geGetContext()->width, geGetContext()->height);
	geLuaCallFunction(script, "sfx.init", "");
	geLuaCallFunction(script, "setup", "");

	double t = geGetTick() / 1000.0;
	char currPage[128] = "";
	int quit = 0;
	int w = geGetContext()->width;
	int h = geGetContext()->height;

	getGameInfos(script, &quit, currPage);

	while(1)
	{
		if(geGetContext()->width != w || geGetContext()->height != h){
			w = geGetContext()->width;
			h = geGetContext()->height;
			geLuaCallFunction(script, "screen.init", "i, i", w, h);
		}

		geReadKeys(keys);
		geClearScreen();

		if(quit){
			break;
		}else{
			bool input = false;
			if(geKeysToggled(keys, GEK_LBUTTON)){
				geLuaCallFunction(script, "screen.page:click", "d, d, d, d", geGetContext()->mouse_x / (float)geGetContext()->width, geGetContext()->mouse_y / (float)geGetContext()->height, 1.0, geGetTick() / 1000.0);
				input = true;
			}
			if(keys->pressed[GEK_LBUTTON] && keys->last[GEK_LBUTTON]){
				geLuaCallFunction(script, "screen.page:touch", "d, d, d, d", geGetContext()->mouse_x / (float)geGetContext()->width, geGetContext()->mouse_y / (float)geGetContext()->height, 1.0, geGetTick() / 1000.0);
				input = true;
			}
			if(input){
				getGameInfos(script, &quit, currPage);
			}

			geLuaCallFunction(script, "screen.update", "d", geGetTick() / 1000.0);
			geLuaCallFunction(script, "screen.page:update", "d, d", geGetTick() / 1000.0, geGetTick() / 1000.0 - t);
			t = geGetTick() / 1000.0;
			getGameInfos(script, &quit, currPage);

			geLuaCallFunction(script, "screen.page:run", "");
			getGameInfos(script, &quit, currPage);
		}

		geSwapBuffers();
	}

#ifdef PLATFORM_android
	exit(0);
#endif
}
