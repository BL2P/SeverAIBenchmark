if (isServer || !hasInterface) then 
{
	//--- set the servers view distance and stuff
	setViewDistance 2000;
	setObjectViewDistance 2000;
	setTerrainGrid 3.125;
	
	// Wait until player or Headless is initialized
	if (!isServer) then
		{
			waitUntil {!isNull player && isPlayer player};
		};
		
		//--- Sort the params
		for '_i' from 0 to (count (missionConfigFile >> "Params"))-1 do 
			{
				_paramName = (configName ((missionConfigFile >> "Params") select _i));
				_value = if (isMultiplayer) then {paramsArray select _i} else {getNumber (missionConfigFile >> "Params" >> _paramName >> "default")};
				missionNamespace setVariable [_paramName, _value];
			};
		sleep 1;
		
		//--- check if headless param is on or off
		if (HEADLESS == 1) then {HEADLESSON = true} else {HEADLESSON = false};
		publicVariable "HEADLESSON";
		
		//--- check if split AI is on
		if (SPLITAI == 1) then {SPLITAION = true}else{SPLITAION = false};
		publicVariable "SPLITAION";
		
		if ((!HEADLESSON) && (SPLITAION)) exitwith {diag_log "SCRIPT STOPPED HEADLESS PARAM OFF";};
		
	//--- run on Headless if headless on	
	if (HEADLESSON && !isServer && !hasinterface && !SPLITAION) then {
		//--- do some stuff
		_script = [] spawn {
			_i = 0;
			_aicount = 0;
			_timer = CREATETIME / 100;
			diag_log "===========AI HEADLESS TEST SETTINGS===========";
			diag_log "**** FPS LIMIT OFF"; //--- always off with headless todo: alow for seperate recorrding of HCFPS and SERVERFPS
			if (SPLITAI > 0) then {diag_log "**** SPLITAI ON";}else{diag_log "**** SPLITAI OFF";};
			diag_log format ["**** HEADLESSON = %1",HEADLESSON];
			diag_log format ["**** FPSLIMIT = %1",FPSLIMIT];
			diag_log format ["**** TIME PER UNIT = %1",_timer];
			diag_log format ["**** AI PER BATCH = %1",AIPERBATCH];
			if (ENABLEFPSLIMIT > 0) then {diag_log format ["**** BATCH   TIME = %1",(BATCHTIME / 2)];}else{diag_log format ["**** BATCH   TIME = %1",BATCHTIME];};
			diag_log format ["**** MAX TOTAL AI = %1",TOTALAI];
			diag_log "=============================================";
			_grp = createGroup west;
			while {true} do {
				sleep _timer;
				helper setPos [(getPos helper select 0)+0.3, (getPos helper select 1)+1,getPos helper select 2];
				_unit = "B_recon_F" createUnit [getPos helper, _grp];
				_i = _i + 1;
				_aicount = _aicount + 1;
				if (_i > (AIPERBATCH - 1)) then {
					_i = 0;
					_grp = createGroup west;
					sleep (BATCHTIME / 2);
					diag_log format ["** Fps = %1 ::: FpsMin = %2 ::: time = %3 ::: _aicount = %4",round diag_fps,round diag_fpsmin,round time,_aicount];
					sleep (BATCHTIME / 2);
				};
				if (_aicount >= TOTALAI) exitwith {
				diag_log format ["======== AI CREATION STOPPED @ %1 AI ========",_aicount];
					while {true} do {
						diag_log format ["---- fps = %1 ::: fpsmin = %2 ::: loop %3sec ::: _aicount = %4",round diag_fps,round diag_fpsmin,(BATCHTIME / 2),_aicount];
						sleep (BATCHTIME / 2);
					};
				};
			};
		};
	};

	//--- run on server if headless off
	if (!HEADLESSON && isServer && !SPLITAION) then {
		//--- do some stuff
		_script = [] spawn {
			_i = 0;
			_aicount = 0;
			_timer = CREATETIME / 100;
			diag_log "===========AI SERVER TEST SETTINGS===========";
			if (ENABLEFPSLIMIT > 0) then {diag_log "**** FPS LIMIT ON";}else{diag_log "**** FPS LIMIT OFF";};
			if (SPLITAI > 0) then {diag_log "**** SPLITAI ON";}else{diag_log "**** SPLITAI OFF";};
			diag_log format ["**** HEADLESSON = %1",HEADLESSON];
			diag_log format ["**** FPSLIMIT = %1",FPSLIMIT];
			diag_log format ["**** TIME PER UNIT = %1",_timer];
			diag_log format ["**** AI PER BATCH = %1",AIPERBATCH];
			if (ENABLEFPSLIMIT > 0) then {diag_log format ["**** BATCH   TIME = %1",(BATCHTIME / 2)];}else{diag_log format ["**** BATCH   TIME = %1",BATCHTIME];};
			diag_log format ["**** MAX TOTAL AI = %1",TOTALAI];
			diag_log "=============================================";
			_grp = createGroup west;
			while {true} do {
				sleep _timer;
				helper setPos [(getPos helper select 0)+0.3, (getPos helper select 1)+1,getPos helper select 2];
				_unit = "B_recon_F" createUnit [getPos helper, _grp];
				_i = _i + 1;
				_aicount = _aicount + 1;
				if (_i > (AIPERBATCH - 1)) then {
					_i = 0;
					_grp = createGroup west;
					sleep (BATCHTIME / 2);
					diag_log format ["** Fps = %1 ::: FpsMin = %2 ::: time = %3 ::: _aicount = %4",round diag_fps,round diag_fpsmin,round time,_aicount];
					if (ENABLEFPSLIMIT > 0) then {
							waituntil {sleep 0.5; diag_fps > FPSLIMIT};
						} else {
							sleep (BATCHTIME / 2);
						};
				};
				if (_aicount >= TOTALAI) exitwith {
				diag_log format ["======== AI CREATION STOPPED @ %1 AI ========",_aicount];
					while {true} do {
						diag_log format ["---- fps = %1 ::: fpsmin = %2 ::: loop %3sec ::: _aicount = %4",round diag_fps,round diag_fpsmin,(BATCHTIME / 2),_aicount];
						sleep (BATCHTIME / 2);
					};
				};
			};
		};
	};
	
	//--- run on headless then on server if split ai is on
	if (SPLITAION) then {
		RUNONSERVER = false;
		if (HEADLESSON && !isServer && !RUNONSERVER) then {
			//--- do some stuff
			_script = [] spawn {
				_i = 0;
				_aicount = 0;
				_timer = CREATETIME / 100;
				diag_log "===========AI HEADLESS TEST SETTINGS SPLIT===========";
				if (ENABLEFPSLIMIT > 0) then {diag_log "**** FPS LIMIT ON";}else{diag_log "**** FPS LIMIT OFF";};
				if (SPLITAI > 0) then {diag_log "**** SPLITAI ON";}else{diag_log "**** SPLITAI OFF";};
				diag_log format ["**** HEADLESSON = %1",HEADLESSON];
				diag_log format ["**** FPSLIMIT = %1",FPSLIMIT];
				diag_log format ["**** TIME PER UNIT = %1",_timer];
				diag_log format ["**** AI PER BATCH = %1",AIPERBATCH];
				if (ENABLEFPSLIMIT > 0) then {diag_log format ["**** BATCH   TIME = %1",(BATCHTIME / 2)];}else{diag_log format ["**** BATCH   TIME = %1",BATCHTIME];};
				diag_log format ["**** MAX TOTAL AI = %1",TOTALAI];
				diag_log "=============================================";
				_grp = createGroup west;
				while {true} do {
					sleep _timer;
					helper setPos [(getPos helper select 0)+0.3, (getPos helper select 1)+1,getPos helper select 2];
					_unit = "B_recon_F" createUnit [getPos helper, _grp];
					_i = _i + 1;
					_aicount = _aicount + 1;
					if (_i > (AIPERBATCH - 1)) then {
						_i = 0;
						_grp = createGroup west;
						if (ENABLEFPSLIMIT > 0) then {sleep (BATCHTIME);}else{sleep (BATCHTIME / 2);};
						diag_log format ["** Fps = %1 ::: FpsMin = %2 ::: time = %3 ::: _aicount = %4",round diag_fps,round diag_fpsmin,round time,_aicount];
						if (ENABLEFPSLIMIT > 0) then 
							{
								if (diag_fps < FPSLIMIT) exitwith {
								diag_log "HEADLESS FPS LIMIT REACHED SWAPPING CREATION EXIT 1";
								RUNONSERVER = true; 
								publicVariable "RUNONSERVER";
							};
						}else{sleep (BATCHTIME / 2);};
					};
					if (RUNONSERVER) exitwith {diag_log "HEADLESS FPS LIMIT REACHED EXIT 2";};
					if (_aicount >= (TOTALAI / 2)) exitwith {
					diag_log format ["======== AI CREATION STOPPED @ %1 AI ========",_aicount];
					RUNONSERVER = true; publicVariable "RUNONSERVER";
						while {true} do {
							diag_log format ["---- HCfps = %1 ::: HCfpsmin = %2 ::: loop %3sec ::: _aicount = %4",round diag_fps,round diag_fpsmin,(BATCHTIME / 2),_aicount];
							sleep (BATCHTIME / 2);
						};
					};
				};
			};
		};
		
		//--- make the server wait until HC has finished creating
		waituntil {sleep 0.5; RUNONSERVER};
		if (HEADLESSON && isServer && RUNONSERVER) then {
			EXITSERVER = false;
			//--- do some stuff
			_script = [] spawn {
				_i = 0;
				_aicount = 0;
				_timer = CREATETIME / 100;
				diag_log "===========AI SERVER TEST SETTINGS SPLIT===========";
				if (ENABLEFPSLIMIT > 0) then {diag_log "**** FPS LIMIT ON";}else{diag_log "**** FPS LIMIT OFF";};
				if (SPLITAI > 0) then {diag_log "**** SPLITAI ON";}else{diag_log "**** SPLITAI OFF";};
				diag_log format ["**** HEADLESSON = %1",HEADLESSON];
				diag_log format ["**** FPSLIMIT = %1",FPSLIMIT];
				diag_log format ["**** TIME PER UNIT = %1",_timer];
				diag_log format ["**** AI PER BATCH = %1",AIPERBATCH];
				if (ENABLEFPSLIMIT > 0) then {diag_log format ["**** BATCH   TIME = %1",(BATCHTIME / 2)];}else{diag_log format ["**** BATCH   TIME = %1",BATCHTIME];};
				diag_log format ["**** MAX TOTAL AI = %1",TOTALAI];
				diag_log "=============================================";
				_grp = createGroup west;
				while {true} do {
					sleep _timer;
					helper setPos [(getPos helper select 0)+0.3, (getPos helper select 1)+1,getPos helper select 2];
					_unit = "B_recon_F" createUnit [getPos helper, _grp];
					_i = _i + 1;
					_aicount = _aicount + 1;
					if (_i > (AIPERBATCH - 1)) then {
						_i = 0;
						_grp = createGroup west;
						if (ENABLEFPSLIMIT > 0) then {sleep (BATCHTIME);}else{sleep (BATCHTIME / 2);};
						diag_log format ["** Fps = %1 ::: FpsMin = %2 ::: time = %3 ::: _aicount = %4",round diag_fps,round diag_fpsmin,round time,_aicount];
						if (ENABLEFPSLIMIT > 0) then 
							{
								if (diag_fps < FPSLIMIT) exitwith {
								diag_log "SERVER FPS LIMIT REACHED EXIT 1";
								EXITSERVER = true;
								publicVariable "EXITSERVER";
								};
						}else{sleep (BATCHTIME / 2);};
					};
					
					if (EXITSERVER) exitwith {diag_log "SERVER FPS LIMIT REACHED EXIT 2";};
					if (_aicount >= TOTALAI / 2) exitwith {
					diag_log format ["======== AI CREATION STOPPED @ %1 AI ========",_aicount];
						while {true} do {
							diag_log format ["---- SRVfps = %1 ::: SRVfpsmin = %2 ::: loop %3sec ::: _aicount = %4",round diag_fps,round diag_fpsmin,(BATCHTIME / 2),_aicount];
							sleep (BATCHTIME / 2);
						};
					};
				};
			};
		};
	};
} else {diag_log "I am not the server OR the Headless";}; 
diag_log "END OF SCRIPT";