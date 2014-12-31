#include <locale.h>
#include <libge/libge.h>
#include <lua5.2/lauxlib.h>
#include "gelua.h"

#define min(a, b) ( ((a) < (b)) ? (a) : (b) )

ge_Font* font = 0;

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

#ifdef PLATFORM_android
	geCreateMainWindow("", -1, -1, 0);
	geCursorVisible(false);
#else
	geCreateMainWindow("GE", 400, 640, GE_WINDOW_RESIZABLE);
#endif

	geWaitVsync(true);
	geClearColor(RGBA(0, 0, 0, 255));

	ge_Keys* keys = geCreateKeys();

	char locale[32] = "";
	setlocale(LC_ALL, "");
	char* flocale = setlocale(LC_ALL, NULL);
	if(flocale){
		strcpy(locale, flocale);
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

	ge_LuaScript* script = geLoadLuaScript("index.lua");
	geLuaDoString(script, gelua);
	geLuaScriptStart(script, GE_LUA_EXECUTION_MODE_NORMAL);

	geLuaCallFunction(script, "screen.setLocale", "s", locale);
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
				geLuaCallFunction(script, "screen.page:click", "d, d, d", geGetContext()->mouse_x / (float)geGetContext()->width, geGetContext()->mouse_y / (float)geGetContext()->height, 1.0);
				input = true;
			}
			if(keys->pressed[GEK_LBUTTON] && keys->last[GEK_LBUTTON]){
				geLuaCallFunction(script, "screen.page:touch", "d, d, d", geGetContext()->mouse_x / (float)geGetContext()->width, geGetContext()->mouse_y / (float)geGetContext()->height, 1.0);
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
