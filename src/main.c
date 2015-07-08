#include <locale.h>
#include <ctype.h>
#include <libge/libge.h>
#include <lua5.2/lua.h>

#include <c30log.h>
#include <md5.h>
#include <gelua.h>
#include <Runnable.h>
#include <ui.Button.h>
#include <ui.InputText.h>
#include <ui.SpinBox.h>
#include <Page.h>
#include <BigMenu.h>
#include <geMenu.h>
#include <net.Socket.h>

#define DECL_RC_BLOB(n) \
	extern char _binary_##n##_lua_start; \
	extern char _binary_##n##_lua_end;

#define RC_BLOB_START(n) &_binary_##n##_lua_start
	
#define RC_BLOB_END(n) &_binary_##n##_lua_end

#ifndef min
#define min(a, b) ( ((a) < (b)) ? (a) : (b) )
#endif

ge_Font* font = 0;
/*
DECL_RC_BLOB(c30log);
DECL_RC_BLOB(ge);
DECL_RC_BLOB(Runnable);
DECL_RC_BLOB(ui_Button);
DECL_RC_BLOB(ui_InputText);
DECL_RC_BLOB(Page);
DECL_RC_BLOB(BigMenu);
DECL_RC_BLOB(Menu);
*/
static int perlin_seed = 42;
void perlin_init2(int seed);
float perlin_noise_2D(float vec[2], int terms, float freq, int seed);
float perlin_noise_3D(float vec[3], int terms, float freq, int seed);

int lua_perlin_noise_Init(ge_LuaScript* script, void* udata){
	perlin_init2( geLuaArgumentInteger(script, 1) );
	return 1;
}

int lua_perlin_noise_2D(ge_LuaScript* script, void* udata){
	float vec[2];
	vec[0] = geLuaArgumentNumber(script, 1);
	vec[1] = geLuaArgumentNumber(script, 2);
	int terms = geLuaArgumentInteger(script, 3);
	float freq = geLuaArgumentNumber(script, 4);
// 	printf("perlin_noise_2D( { %.2f, %.2f }, %d, %.2f, %d )\n", vec[0], vec[1], terms, freq);
	float ret = perlin_noise_2D(vec, terms, freq, perlin_seed);
// 	printf("  ret = %.2f\n", ret);
	lua_pushnumber(script->L, (double)ret);
	return 1;
}

int lua_perlin_noise_3D(ge_LuaScript* script, void* udata){
	return 1;
}

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
	char* index = "index.lua";
	if(ac > 1 && !strcmp(av[1], "--debug")){
		geDebugMode(GE_DEBUG_ALL);
		if(ac > 2){
			index = av[2];
		}
	}
	if(ac > 1 && strcmp(av[1], "--debug")){
		index = av[1];
	}
#if (defined(PLATFORM_android) || defined(PLATFORM_ios))
		geDebugMode(GE_DEBUG_ALL);
#endif

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

	geLuaAddFunction(script, lua_perlin_noise_2D, "perlin2D", NULL);
	geLuaAddFunction(script, lua_perlin_noise_Init, "perlinInit", NULL);

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

	geLuaTableOpen(script, "screen", true);
	bool fs = geLuaTableVariableBooleanByName(script, "fullscreen");
	bool rz = geLuaTableVariableBooleanByName(script, "resizable");
	const char* title = geLuaTableVariableStringByName(script, "title");
	int width = geLuaTableVariableIntegerByName(script, "width");
	int height = geLuaTableVariableIntegerByName(script, "height");
	int flags = (fs ? GE_WINDOW_FULLSCREEN : 0) | (rz ? GE_WINDOW_RESIZABLE : 0);
	geLuaTableClose(script);

	geCreateMainWindow(title, width, height, flags);
#ifdef PLATFORM_android
	geCursorVisible(false);
#endif

	geWaitVsync(true);
// 	geWaitVsync(false);
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
	geLuaDoString(script, h_c30log);
	geLuaDoString(script, h_md5);
	geLuaDoString(script, h_gelua);
	geLuaDoString(script, h_Runnable);
	geLuaDoString(script, h_uiButton);
	geLuaDoString(script, h_uiInputText);
	geLuaDoString(script, h_uiSpinBox);
	geLuaDoString(script, h_Page);
	geLuaDoString(script, h_BigMenu);
	geLuaDoString(script, h_geMenu);
	geLuaDoString(script, h_netSocket);

	gePrintDebug(0, "A \n");
	geLuaDoFile(script, index);
	gePrintDebug(0, "B \n");

	if(geFileExists(locale_lua)){
		geLuaCallFunction(script, "screen.setLocale", "s", locale);
	}
	geLuaCallFunction(script, "screen.init", "d, d", (float)geGetContext()->width, (float)geGetContext()->height);
	geLuaCallFunction(script, "sfx.init", "");
	geLuaCallFunction(script, "setup", "");

	u32 fps_ticks = 0;
	double t = geGetTick() / 1000.0;
	double dt = 0.0;
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
			geLuaCallFunction(script, "screen.page:baseinit", "");
		}

		geReadKeys(keys);
		geClearScreen();

		if(quit){
			break;
		}else{
			bool input = false;
			if(geKeysUnToggled(keys, GEK_LBUTTON)){
				geLuaCallFunction(script, "screen.page:click", "d, d, d, d", geGetContext()->mouse_x / (float)geGetContext()->width, geGetContext()->mouse_y / (float)geGetContext()->height, 1.0, geGetTickFloat());
				input = true;
			}
			if(keys->pressed[GEK_LBUTTON] && keys->last[GEK_LBUTTON]){
				geLuaCallFunction(script, "screen.page:touch", "d, d, d, d", geGetContext()->mouse_x / (float)geGetContext()->width, geGetContext()->mouse_y / (float)geGetContext()->height, 1.0, geGetTickFloat());
				input = true;
			}
			if(!keys->pressed[GEK_LBUTTON] && keys->last[GEK_LBUTTON]){
				geLuaCallFunction(script, "screen.page:touch", "d, d, d, d", geGetContext()->mouse_x / (float)geGetContext()->width, geGetContext()->mouse_y / (float)geGetContext()->height, 0.0, geGetTickFloat());
				input = true;
			}
			if(input){
				getGameInfos(script, &quit, currPage);
			}

			geLuaCallFunction(script, "screen.update", "d", geGetTickFloat());
			geLuaCallFunction(script, "screen.page:update", "d, d", geGetTickFloat(), dt);
			getGameInfos(script, &quit, currPage);

			geLuaCallFunction(script, "screen.page:run", "");
			getGameInfos(script, &quit, currPage);
		}

#if (defined(PLATFORM_android) || defined(PLATFORM_ios))
		fps_ticks = geWaitTick(1000 / 60, fps_ticks);
#else
		fps_ticks = geWaitTick(1000 / 60, fps_ticks);
#endif
		geSwapBuffers();
		dt = geGetTickFloat() - t;
		t = geGetTickFloat();
	}

#ifdef PLATFORM_android
	exit(0);
#endif
}
