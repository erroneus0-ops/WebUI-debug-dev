// List of software to present to the user in drop-down menus.

const software = [

	{
		'name': 'Games',
		'description': 'Games',
		'entries': [

			{
				'name': 'Blockdown',
				'title': '<a href="/blockdown/">Blockdown</a>',
				'author': '2021 Ciaran Anscomb',
				'text': '<p>Falling blocks puzzle game for the Dragon 32/64 and Tandy Colour Computer. 1 or 2 players! Written in 100% Machine Code!',
				'machine': 'dragon32',
				'autorun': 'blockdown.rom',
			},

			{
				'name': 'Blockdown GMC',
				'title': '<a href="/blockdown/gmc.shtml">Blockdown GMC</a>',
				'author': '2022 Ciaran Anscomb',
				'text': '<p>Falling blocks puzzle game for the Dragon 32/64 and Tandy Colour Computer. 1 or 2 players! Written in 100% Machine Code!<p>Utilises John Linville\'s Games Master Cartridge for background music and sound effects.',
				'machine': 'dragon32',
				'autorun': 'blockdown-gmc.rom',
			},

			{
				'name': 'Bob and the Alien Fire Flies',
				'title': '<a href="https://8bitsinthebasement.itch.io/">Bob and the Alien Fire Flies</a>',
				'author': '© 2024 8bitsinthebasement',
				'text': '<p>Bob, a curious little hedgehog has just stumbled upon a small moonlit glade. Within it he\'s found some of the most delicious little glowing alien bugs that he has ever tasted.<p>Free original arcade game from 8bitsinthebasement.',
				'machine': 'dragon32',
				'autorun': 'drabob12.cas',
				'joy_left': 'kjoy0',
			},

			{
				'name': 'Christmas Match',
				'title': '<a href="https://pshoemaker70.itch.io/christmas-match">Christmas Match</a>',
				'author': '© 2024 Paul Shoemaker',
				'text': '<p>Use your analog joystick to flip over cards and locate the matched pairs.  Clear the first board and the next one gets a little harder with more cards.  There is no score and the game never ends.  However, you can press "Q" while on a game board to return to the title screen.  Pressing "Q" on the title screen will return to BASIC.',
				'machine': 'dragon32',
				'cart': 'dragondos',
				'joy_right': 'mjoy0',
				'autorun': 'xmasmatch.dsk',
			},

			{
				'name': 'Christmas Match (CoCo 3)',
				'title': '<a href="https://pshoemaker70.itch.io/christmas-match">Christmas Match</a>',
				'author': '© 2024 Paul Shoemaker',
				'text': '<p>Use your analog joystick to flip over cards and locate the matched pairs.  Clear the first board and the next one gets a little harder with more cards.  There is no score and the game never ends.  However, you can press "Q" while on a game board to return to the title screen.  Pressing "Q" on the title screen will return to BASIC.',
				'machine': 'coco3',
				'cart': 'rsdos',
				'joy_right': 'mjoy0',
				'tv_input': 3,
				'disk0': 'xmasmatch.dsk',
				'basic': '\bLOADM"MATCHCC3":EXEC\r11',
			},

			{
				'name': 'Dragonfire (PAL fixed)',
				'author': 'Imagic, Torsten Dittel',
				'machine': 'coco',
				'text': '<p>Torsten Dittel\'s PAL fix of the NTSC original, including a fancy intro screen.',
				'autorun': '/dittel/DRAGFIR2.BIN',
				'joy_left': 'kjoy0',
			},

			{
				'name': 'Dunjunz',
				'title': '<a href="/dunjunz/">Dunjunz</a>',
				'author': '2018 Ciaran Anscomb',
				'text': '<p>25 levels of monsters & magic for the Dragon 32/64 and Tandy Colour Computer. 1–4 simultaneous players! Written in 100% Machine Code!<p>Based on the BBC Micro original by Julian Avis.',
				'machine': 'dragon64',
				'autorun': 'dunjunz.cas',
			},

			{
				'name': 'Dunjunz GMC',
				'title': '<a href="/dunjunz/gmc.shtml">Dunjunz GMC</a>',
				'author': '2020 Ciaran Anscomb',
				'text': '<p>25 levels of monsters & magic for the Dragon 32/64 and Tandy Colour Computer. 1–4 simultaneous players! Written in 100% Machine Code!<p>Based on the BBC Micro original by Julian Avis.<p>Utilises John Linville\'s Games Master Cartridge for title music and sound effects.',
				'machine': 'dragon32',
				'autorun': 'dunjunz.rom',
			},

			{
				'name': 'Flee!',
				'author': '© 1985 Colin Hogg, J Dave Rogers',
				'publisher': 'Dragon User, March 1986',
				'text': '<p>\'Pac Man\' style game using semigraphics.',
				'machine': 'dragon32',
				'autorun': 'flee.cas',
			},

			{
				'name': 'Goop Rush',
				'author': '© 2024 Paul Shoemaker',
				'text': '<p>Avoid the falling buzzer blades and the occasional glowing, shambling horror.  If an enemy touches you, your radiation level will increase quickly!',
				'machine': 'dragon64',
				'cart': 'dragondos',
				'joy_right': 'kjoy0',
				'autorun': 'gooprush.dsk',
			},

			{
				'name': 'Lava Hero',
				'author': '© 2024 Paul Shoemaker',
				'text': '<p>Hold the button to build your bridge.  Let go when you think it is long enough.  When running, tap the button to go under to collect gems.  Tap the button again to go back to the top!',
				'machine': 'tano',
				'cart': 'dragondos',
				'joy_right': 'kjoy0',
				'autorun': 'lavahero.dsk',
			},

			{
				'name': 'Lava Hero (CoCo 3)',
				'author': '© 2024 Paul Shoemaker',
				'text': '<p>Hold the button to build your bridge.  Let go when you think it is long enough.  When running, tap the button to go under to collect gems.  Tap the button again to go back to the top!',
				'machine': 'coco3',
				'cart': 'rsdos',
				'joy_right': 'kjoy0',
				'disk0': 'lavahero.dsk',
				'tv_input': 3,
				'basic': '\bLOADM"LAVAHERO":EXEC\r11',
			},

			{
				'name': 'Pac-Man (MC-10)',
				'author': '© 2006 Greg Dionne',
				'machine': 'mc10',
				'text': '<p>\'Pac Man\', expertly adapted to the MC-10.',
				'autorun': 'pac-man.c10',
			},

			{
				'name': 'Star Trek III',
				'publisher': '© 1981 Adventure International',
				'machine': 'dragon32',
				'cart': 'dragondos',
				'joy_right': 'mjoy0',
				'autorun': 'trekiii.dsk',
			},

			{
				'name': 'Tea Time',
				'author': 'Adrian Eddleston',
				'publisher': '© 1984 Pocket Money Software',
				'text': '<p>Catch the falling tea and keep your mug full, then dodge the sugar cubes on your way to the pantry to restock your tea supplies from the shelves by using the lifts and finally "dock" your teapot in the safety of the teacosy.  Arcade action game.  Joystick Required.',
				'machine': 'dragon32',
				'joy_right': 'kjoy0',
				'autorun': 'tea_time.cas',
			},

			{
				'name': 'Tetris',
				'author': '© 1991 Ola Eldøy',
				'publisher': 'PSE Computers',
				'text': '<p>Another version of the falling blocks puzzle game, featuring sampled sound and PAL colour blending.',
				'machine': 'dragon32',
				'cart': 'dragondos',
				'cart_rom': 'sdose6.rom',
				'joy_right': 'kjoy0',
				'autorun': 'tetris.vdk',
			},

			{
				'name': 'Xmas Rush (MC-10)',
				'author': '© 2016 John Linville',
				'machine': 'mc10',
				'text': '<p>Christmas themed video game.<p>Enter the forest and find the last evergreen tree. Then escape with the tree avoiding the evil snowmen.',
				'autorun': 'xmasrush.c10',
			},

		]
	},

	{
		'name': 'OS &amp; Apps',
		'description': 'Operating Systems and Applications',
		'entries': [

			{
				'tag': 'fuzix-mooh',
				'name': 'Fuzix (MOOH)',
				'title': '<a href="https://fuzix.org/">Fuzix</a> using the <a href="http://tormod.me/mooh.html">MOOH</a>',
				'machine': 'dragon64',
				'text': '<p>Fuzix running with <a href="http://tormod.me/mooh.html">Tormod Volden\'s MOOH board</a>.',
				'cart': 'mooh',
				'hd0': 'fuzix-mooh.img',
			},

			{
				'tag': 'fuzix-coco3',
				'name': 'Fuzix (CoCo 3)',
				'title': '<a href="https://fuzix.org/">Fuzix</a> on the CoCo 3',
				'machine': 'coco3',
				'text': '<p>Fuzix running on a Tandy CoCo 3.',
				'cart': 'ide',
				'hd0': 'fuzix-coco3.img',
				'tv_input': 3,
			},

			{
				'tag': 'hires',
				'name': 'Hi-res Screen Driver',
				'author': 'Paul Harrison, Ciaran Anscomb',
				'machine': 'dragon64',
				'text': '<p>Based on the 64 column screen driver by Paul Harrison published in Dragon User, December 1987.',
				'cart': 'dragondos',
				'cart_rom': 'dplus49b.rom',
				'disk0': 'hires.vdk',
				'basic': '\bRUN"HIRES.BIN"\r',
			},

			{
				'name': 'Magic Guru',
				'author': '© 1986 Max Hantsch',
				'text': '<p>The Most Advanced Graphic Interface Controller with a Graphic User Relationship Utility.<p>Demo of a potential WIMP system.',
				'machine': 'dragon64',
				'cart': 'dragondos',
				'cart_rom': 'sdose6.rom',
				'joy_right': 'mjoy0',
				'disk0': 'magic1.vdk',
				'disk1': 'magic2.vdk',
				'basic': 'BOOT\r',
			},

			{
				'tag': 'nitros9',
				'name': 'NitrOS-9',
				'title': '<a href="http://www.nitros9.org/">NitrOS-9</a>',
				'machine': 'dragon64',
				'text': '<p>The NitrOS-9 Operating System built for the Dragon 64, on an 80 track floppy image.',
				'cart': 'dragondos',
				'autorun': 'NOS9_6809_L1_v030300_d64_80d.dsk',
			},

			{
				'tag': 'nitros9-mooh',
				'name': 'NitrOS-9 (MOOH)',
				'title': '<a href="http://www.nitros9.org/">NitrOS-9</a> using the <a href="http://tormod.me/mooh.html">MOOH</a>',
				'machine': 'dragon64',
				'text': '<p>NitrOS-9 running with <a href="http://tormod.me/mooh.html">Tormod Volden\'s MOOH board</a>.',
				'cart': 'mooh',
				'hd0': 'mooh-nitros9-co42.img',
			},

			{
				'tag': 'eou',
				'name': 'NitrOS-9 Ease of Use (CoCo 3)',
				'title': '<a href="https://github.com/n6il/eou_ide">NitrOS-9 Ease of Use</a>',
				'machine': 'coco3p',
				'text': '<p>Running on a 512K PAL CoCo 3, adapted to IDE using Michael Furman\'s kit.<p>Remember, the same 128MB HD image is downloaded each time, and held in RAM.  No changes will persist across sessions.',
				'cart': 'ide',
				'cart_rom': 'yados.rom',
				'hd0': '68IDE.img',
				'basic': '\bDOS\r',
			},

		]
	},

	{
		'name': 'Demos',
		'description': 'Demos',
		'entries': [

			{
				'name': '512-byte Text Mode Scrolling Demo',
				'title': '<a href="/dragon/demo/#512scroll">512-byte Text Mode Scrolling Demo</a>',
				'author': '© 2021 Ciaran Anscomb',
				'text': '<p>Smooth vertical scrolling in text mode using the VDG.<p>Demonstrates the ability to arbitrarily offset the MC6847\'s built-in font vertically.',
				'machine': 'dragon32',
				'autorun': '512scroll.cas',
			},

			{
				'name': 'Amiga Ball',
				'author': '© 1986 Martin Herhaus',
				'text': '<p>Dragon version of the famous Amiga bouncing ball demo.',
				'machine': 'dragon32',
				'cart': 'dragondos',
				'cart_rom': 'sdose6.rom',
				'disk0': 'amiga_ball.vdk',
				'basic': 'RUN"AMIGA"\r',
			},

			{
				'name': 'Bluebelle Vertical Scrolling Demo',
				'title': '<a href="/dev/tm002/">Bluebelle Vertical Scrolling Demo</a>',
				'author': '© 2020 Ciaran Anscomb',
				'text': '<p>Hardware vertical scrolling exploiting an undocumented feature of the SAM.',
				'machine': 'dragon32',
				'autorun': 'bbscroll.rom',
			},

			{
				'name': 'CoCoFEST GMC Demo',
				'author': 'John W Linville',
				'text': '<p>Musical demo of John Linville\'s Games Master Cartridge.',
				'machine': 'cocous',
				'autorun': 'cocofest.rom',
			},

			{
				'name': 'Conway\'s Game of Life',
				'author': '© 2020 Ciaran Anscomb',
				'text': '<p>Written in tribute to John Conway, who died this year (2020) from COVID-19.',
				'machine': 'dragon32',
				'autorun': 'life16.cas',
			},

			{
				'name': 'Covid Kid (CoCo 3)',
				'author': '© 2021 Simon Jonassen',
				'text': '<p>Neat looking palette-cycling demo with impressive sampled music.',
				'machine': 'coco3',
				'cart': 'rsdos',
				'disk0': 'scared.dmk',
				'basic': 'DOS\r',
				'tv_input': 3,
			},

			{
				'name': 'Moving Demo (Mandelbrot)',
				'author': '© 1986 Lothar Fritsch',
				'machine': 'dragon32',
				'cart': 'dragondos',
				'cart_rom': 'sdose6.rom',
				'disk0': 'amiga_ball.vdk',
				'basic': 'RUN"DEMO"\r',
			},

			{
				'name': 'Nyan Cat',
				'title': '<a href="/dragon/demo/#nyan">Nyan Cat</a>',
				'author': '© 2011 Ciaran Anscomb',
				'text': '<p>Dragon version of the famous animation.  Three-channel music (one sample, two waveforms).',
				'machine': 'dragon64',
				'autorun': 'nyan-dragon.cas',
			},

			{
				'name': 'Test Card: GIME',
				'author': '© 2023 Ciaran Anscomb',
				'text': '<p>Display every colour from the GIME on one screen.',
				'machine': 'coco3',
				'cart': 'rsdos',
				'disk0': 'testcard.dsk',
				'basic': 'DOS\r',
			},

			{
				'name': 'Test Card: Semigraphics 4',
				'author': '© 2023 Ciaran Anscomb',
				'text': '<p>Display every colour from the VDG on one simple text screen.',
				'machine': 'dragon32',
				'cart': 'dragondos',
				'cart_rom': 'sdose6.rom',
				'autorun': 'testcard.dsk',
			},

			{
				'name': 'Sock Master Drive Thru Demo (CoCo 3)',
				'title': '<a href="/twilight/sock/cocofile/demo.html">Sock Master Drive Thru Demo (CoCo 3)</a>',
				'author': 'John Kowalski',
				'machine': 'coco3',
				'cart': 'rsdos',
				'disk0': 'sockmst.dsk',
				'basic': 'LOADM"DEMO"\r\rEXEC\r',
				'tv_input': 3,
			},

			{
				'tag': 'ta2018',
				'name': 'Tandy Assembly Demo (TA2018)',
				'author': '© 2018 Simon Jonassen',
				'machine': 'cocous',
				'cart': 'rsdos',
				'disk0': 'asmdemo.dsk',
				'basic': 'LOADM"ASM-AUTO"\r',
			},

			{
				'name': 'Twinkles',
				'title': 'Twinkles',
				'author': '© 2020 Ciaran Anscomb',
				'text': '<p>Pretty twinkling things.',
				'machine': 'dragon32',
				'autorun': 'twinkles.cas',
			},

		]
	},

	{
		'name': 'Music',
		'description': 'Music',
		'entries': [

			{
				'name': 'Celtic1',
				'author': 'Noise (MOD), Wayne Smithson / Ciaran Anscomb (player)',
				'text': '<p>Music from the Bob Revolution demo for the Amiga by Celtic. As a youth, I sampled this using Wayne Smithson\'s Soundhouse and sequenced with crufty tools.',
				'machine': 'dragon64',
				'cart': 'dragondos',
				'cart_rom': 'sdose6.rom',
				'disk0': 'celtic1.dsk',
				'basic': 'RUN"MUSIC"\r',
			},

			{
				'name': 'CyD - Ghosts \'n Goblins',
				'author': 'Mark Cooksey (SID), Ciaran Anscomb (player)',
				'machine': 'dragon32',
				'text': '<p>A brute-force conversion from SID to CyD.  No effort made to compact repeated data, only runs for as long as there is memory.',
				'autorun': 'cyd-gng.cas',
			},

			{
				'name': 'CyD - Head Over Heels',
				'author': 'Peter Clarke (SID), Ciaran Anscomb (player)',
				'text': '<p>A brute-force conversion from SID to CyD.  No effort made to compact repeated data, only runs for as long as there is memory.',
				'machine': 'dragon32',
				'autorun': 'cyd-hoh.cas',
			},

			{
				'name': 'CyD - Rasputin',
				'author': 'Rob Hubbard (SID), Ciaran Anscomb (player)',
				'text': '<p>A brute-force conversion from SID to CyD.  No effort made to compact repeated data, only runs for as long as there is memory.',
				'machine': 'dragon32',
				'autorun': 'cyd-rasputin.cas',
			},

			{
				'name': 'CyD - R-Type',
				'author': 'Chris Hülsbeck (SID), Ciaran Anscomb (player)',
				'text': '<p>A brute-force conversion from SID to CyD.  No effort made to compact repeated data, only runs for as long as there is memory.',
				'machine': 'dragon32',
				'autorun': 'cyd-rtype.cas',
			},

			{
				'name': 'Dragon Carousel',
				'publisher': '© 1989 Dragonfire Services',
				'machine': 'dragon32',
				'cart': 'dragondos',
				'cart_rom': 'dplus49b.rom',
				'disk0': 'dragon_carousel.vdk',
				'basic': '\bRUN"MPLAYER.BIN"\r',
			},

			{
				'name': 'El Pea',
				'author': '© 1986 Starship Software',
				'publisher': '© 1986 Microvision Software',
				'machine': 'dragon32',
				'cart': 'dragondos',
				'cart_rom': 'sdose6.rom',
				'disk0': 'el_pea.vdk',
				'basic': 'RUN"MENU"\r',
			},

		]
	},

	{
		'name': 'Prototypes',
		'description': 'Hardware prototypes',
		'entries': [

			{
				'name': 'Dragon Professional w/ DragonDOS',
				'publisher': 'Dragon Data Ltd',
				'text': '<p>Experimental Dragon Professional emulation.  DragonDOS 2.F is inserted into Drive 1, press &lt;D&gt; at the Boot ROM screen, then &lt;ENTER&gt; when prompted.  Probably bad AY audio emulation, no ACIA.',
				'machine': 'dragonpro',
				'disk0': 'ddos2f.vdk',
			},

			{
				'name': 'Dragon Professional w/ OS-9',
				'publisher': 'Dragon Data Ltd',
				'text': '<p>Experimental Dragon Professional emulation.  OS-9 system disk is inserted into Drive 1, press &lt;D&gt; at the Boot ROM screen, then &lt;ENTER&gt; when prompted.  Probably bad AY audio emulation, no ACIA.',
				'machine': 'dragonpro',
				'disk0': 'os9sys_dpro.vdk',
			},

			{
				'name': 'Tandy Deluxe CoCo',
				'publisher': 'Tandy',
				'text': '<p>Experimental Tandy Deluxe Color Computer emulation.  Probably bad AY audio emulation, no ACIA.',
				'machine': 'deluxecoco',
			},

		]
	},

];
