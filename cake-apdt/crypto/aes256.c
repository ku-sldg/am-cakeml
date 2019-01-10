#include "aes256.h"

void aes256_expand_key(const uint32_t *key,
                       uint32_t *encKS) {
  const uint32_t s0 = key[0];
  const uint32_t s1 = key[1];
  const uint32_t s2 = key[2];
  const uint32_t s3 = key[3];
  const uint32_t s4 = key[4];
  const uint32_t s5 = key[5];
  const uint32_t s6 = key[6];
  const uint32_t s7 = key[7];
  static const uint8_t table0[] = {
       99, 124, 119, 123, 242, 107, 111, 197,  48,   1, 103,  43, 254,
      215, 171, 118, 202, 130, 201, 125, 250,  89,  71, 240, 173, 212,
      162, 175, 156, 164, 114, 192, 183, 253, 147,  38,  54,  63, 247,
      204,  52, 165, 229, 241, 113, 216,  49,  21,   4, 199,  35, 195,
       24, 150,   5, 154,   7,  18, 128, 226, 235,  39, 178, 117,   9,
      131,  44,  26,  27, 110,  90, 160,  82,  59, 214, 179,  41, 227,
       47, 132,  83, 209,   0, 237,  32, 252, 177,  91, 106, 203, 190,
       57,  74,  76,  88, 207, 208, 239, 170, 251,  67,  77,  51, 133,
       69, 249,   2, 127,  80,  60, 159, 168,  81, 163,  64, 143, 146,
      157,  56, 245, 188, 182, 218,  33,  16, 255, 243, 210, 205,  12,
       19, 236,  95, 151,  68,  23, 196, 167, 126,  61, 100,  93,  25,
      115,  96, 129,  79, 220,  34,  42, 144, 136,  70, 238, 184,  20,
      222,  94,  11, 219, 224,  50,  58,  10,  73,   6,  36,  92, 194,
      211, 172,  98, 145, 149, 228, 121, 231, 200,  55, 109, 141, 213,
       78, 169, 108,  86, 244, 234, 101, 122, 174,   8, 186, 120,  37,
       46,  28, 166, 180, 198, 232, 221, 116,  31,  75, 189, 139, 138,
      112,  62, 181, 102,  72,   3, 246,  14,  97,  53,  87, 185, 134,
      193,  29, 158, 225, 248, 152,  17, 105, 217, 142, 148, 155,  30,
      135, 233, 206,  85,  40, 223, 140, 161, 137,  13, 191, 230,  66,
      104,  65, 153,  45,  15, 176,  84, 187,  22
  };
  const uint32_t s264 = (s7 << 8) | (s7 >> 24);
  const uint16_t s265 = (uint16_t) (s264 >> 16);
  const uint8_t  s266 = (uint8_t) (s265 >> 8);
  const uint8_t  s267 = table0[s266];
  const uint8_t  s268 = 1 ^ s267;
  const uint8_t  s269 = (uint8_t) s265;
  const uint8_t  s270 = table0[s269];
  const uint16_t s271 = (((uint16_t) s268) << 8) | ((uint16_t) s270);
  const uint16_t s272 = (uint16_t) s264;
  const uint8_t  s273 = (uint8_t) (s272 >> 8);
  const uint8_t  s274 = table0[s273];
  const uint8_t  s275 = (uint8_t) s272;
  const uint8_t  s276 = table0[s275];
  const uint16_t s277 = (((uint16_t) s274) << 8) | ((uint16_t) s276);
  const uint32_t s278 = (((uint32_t) s271) << 16) | ((uint32_t) s277);
  const uint32_t s279 = s0 ^ s278;
  const uint32_t s280 = s1 ^ s279;
  const uint32_t s281 = s2 ^ s280;
  const uint32_t s282 = s3 ^ s281;
  const uint16_t s283 = (uint16_t) (s282 >> 16);
  const uint8_t  s284 = (uint8_t) (s283 >> 8);
  const uint8_t  s285 = table0[s284];
  const uint8_t  s286 = (uint8_t) s283;
  const uint8_t  s287 = table0[s286];
  const uint16_t s288 = (((uint16_t) s285) << 8) | ((uint16_t) s287);
  const uint16_t s289 = (uint16_t) s282;
  const uint8_t  s290 = (uint8_t) (s289 >> 8);
  const uint8_t  s291 = table0[s290];
  const uint8_t  s292 = (uint8_t) s289;
  const uint8_t  s293 = table0[s292];
  const uint16_t s294 = (((uint16_t) s291) << 8) | ((uint16_t) s293);
  const uint32_t s295 = (((uint32_t) s288) << 16) | ((uint32_t) s294);
  const uint32_t s296 = s4 ^ s295;
  const uint32_t s297 = s5 ^ s296;
  const uint32_t s298 = s6 ^ s297;
  const uint32_t s299 = s7 ^ s298;
  const uint32_t s300 = (s299 << 8) | (s299 >> 24);
  const uint16_t s301 = (uint16_t) (s300 >> 16);
  const uint8_t  s302 = (uint8_t) (s301 >> 8);
  const uint8_t  s303 = table0[s302];
  const uint8_t  s304 = 2 ^ s303;
  const uint8_t  s305 = (uint8_t) s301;
  const uint8_t  s306 = table0[s305];
  const uint16_t s307 = (((uint16_t) s304) << 8) | ((uint16_t) s306);
  const uint16_t s308 = (uint16_t) s300;
  const uint8_t  s309 = (uint8_t) (s308 >> 8);
  const uint8_t  s310 = table0[s309];
  const uint8_t  s311 = (uint8_t) s308;
  const uint8_t  s312 = table0[s311];
  const uint16_t s313 = (((uint16_t) s310) << 8) | ((uint16_t) s312);
  const uint32_t s314 = (((uint32_t) s307) << 16) | ((uint32_t) s313);
  const uint32_t s315 = s279 ^ s314;
  const uint32_t s316 = s280 ^ s315;
  const uint32_t s317 = s281 ^ s316;
  const uint32_t s318 = s282 ^ s317;
  const uint16_t s319 = (uint16_t) (s318 >> 16);
  const uint8_t  s320 = (uint8_t) (s319 >> 8);
  const uint8_t  s321 = table0[s320];
  const uint8_t  s322 = (uint8_t) s319;
  const uint8_t  s323 = table0[s322];
  const uint16_t s324 = (((uint16_t) s321) << 8) | ((uint16_t) s323);
  const uint16_t s325 = (uint16_t) s318;
  const uint8_t  s326 = (uint8_t) (s325 >> 8);
  const uint8_t  s327 = table0[s326];
  const uint8_t  s328 = (uint8_t) s325;
  const uint8_t  s329 = table0[s328];
  const uint16_t s330 = (((uint16_t) s327) << 8) | ((uint16_t) s329);
  const uint32_t s331 = (((uint32_t) s324) << 16) | ((uint32_t) s330);
  const uint32_t s332 = s296 ^ s331;
  const uint32_t s333 = s297 ^ s332;
  const uint32_t s334 = s298 ^ s333;
  const uint32_t s335 = s299 ^ s334;
  const uint32_t s336 = (s335 << 8) | (s335 >> 24);
  const uint16_t s337 = (uint16_t) (s336 >> 16);
  const uint8_t  s338 = (uint8_t) (s337 >> 8);
  const uint8_t  s339 = table0[s338];
  const uint8_t  s340 = 4 ^ s339;
  const uint8_t  s341 = (uint8_t) s337;
  const uint8_t  s342 = table0[s341];
  const uint16_t s343 = (((uint16_t) s340) << 8) | ((uint16_t) s342);
  const uint16_t s344 = (uint16_t) s336;
  const uint8_t  s345 = (uint8_t) (s344 >> 8);
  const uint8_t  s346 = table0[s345];
  const uint8_t  s347 = (uint8_t) s344;
  const uint8_t  s348 = table0[s347];
  const uint16_t s349 = (((uint16_t) s346) << 8) | ((uint16_t) s348);
  const uint32_t s350 = (((uint32_t) s343) << 16) | ((uint32_t) s349);
  const uint32_t s351 = s315 ^ s350;
  const uint32_t s352 = s316 ^ s351;
  const uint32_t s353 = s317 ^ s352;
  const uint32_t s354 = s318 ^ s353;
  const uint16_t s355 = (uint16_t) (s354 >> 16);
  const uint8_t  s356 = (uint8_t) (s355 >> 8);
  const uint8_t  s357 = table0[s356];
  const uint8_t  s358 = (uint8_t) s355;
  const uint8_t  s359 = table0[s358];
  const uint16_t s360 = (((uint16_t) s357) << 8) | ((uint16_t) s359);
  const uint16_t s361 = (uint16_t) s354;
  const uint8_t  s362 = (uint8_t) (s361 >> 8);
  const uint8_t  s363 = table0[s362];
  const uint8_t  s364 = (uint8_t) s361;
  const uint8_t  s365 = table0[s364];
  const uint16_t s366 = (((uint16_t) s363) << 8) | ((uint16_t) s365);
  const uint32_t s367 = (((uint32_t) s360) << 16) | ((uint32_t) s366);
  const uint32_t s368 = s332 ^ s367;
  const uint32_t s369 = s333 ^ s368;
  const uint32_t s370 = s334 ^ s369;
  const uint32_t s371 = s335 ^ s370;
  const uint32_t s372 = (s371 << 8) | (s371 >> 24);
  const uint16_t s373 = (uint16_t) (s372 >> 16);
  const uint8_t  s374 = (uint8_t) (s373 >> 8);
  const uint8_t  s375 = table0[s374];
  const uint8_t  s376 = 8 ^ s375;
  const uint8_t  s377 = (uint8_t) s373;
  const uint8_t  s378 = table0[s377];
  const uint16_t s379 = (((uint16_t) s376) << 8) | ((uint16_t) s378);
  const uint16_t s380 = (uint16_t) s372;
  const uint8_t  s381 = (uint8_t) (s380 >> 8);
  const uint8_t  s382 = table0[s381];
  const uint8_t  s383 = (uint8_t) s380;
  const uint8_t  s384 = table0[s383];
  const uint16_t s385 = (((uint16_t) s382) << 8) | ((uint16_t) s384);
  const uint32_t s386 = (((uint32_t) s379) << 16) | ((uint32_t) s385);
  const uint32_t s387 = s351 ^ s386;
  const uint32_t s388 = s352 ^ s387;
  const uint32_t s389 = s353 ^ s388;
  const uint32_t s390 = s354 ^ s389;
  const uint16_t s391 = (uint16_t) (s390 >> 16);
  const uint8_t  s392 = (uint8_t) (s391 >> 8);
  const uint8_t  s393 = table0[s392];
  const uint8_t  s394 = (uint8_t) s391;
  const uint8_t  s395 = table0[s394];
  const uint16_t s396 = (((uint16_t) s393) << 8) | ((uint16_t) s395);
  const uint16_t s397 = (uint16_t) s390;
  const uint8_t  s398 = (uint8_t) (s397 >> 8);
  const uint8_t  s399 = table0[s398];
  const uint8_t  s400 = (uint8_t) s397;
  const uint8_t  s401 = table0[s400];
  const uint16_t s402 = (((uint16_t) s399) << 8) | ((uint16_t) s401);
  const uint32_t s403 = (((uint32_t) s396) << 16) | ((uint32_t) s402);
  const uint32_t s404 = s368 ^ s403;
  const uint32_t s405 = s369 ^ s404;
  const uint32_t s406 = s370 ^ s405;
  const uint32_t s407 = s371 ^ s406;
  const uint32_t s408 = (s407 << 8) | (s407 >> 24);
  const uint16_t s409 = (uint16_t) (s408 >> 16);
  const uint8_t  s410 = (uint8_t) (s409 >> 8);
  const uint8_t  s411 = table0[s410];
  const uint8_t  s412 = 16 ^ s411;
  const uint8_t  s413 = (uint8_t) s409;
  const uint8_t  s414 = table0[s413];
  const uint16_t s415 = (((uint16_t) s412) << 8) | ((uint16_t) s414);
  const uint16_t s416 = (uint16_t) s408;
  const uint8_t  s417 = (uint8_t) (s416 >> 8);
  const uint8_t  s418 = table0[s417];
  const uint8_t  s419 = (uint8_t) s416;
  const uint8_t  s420 = table0[s419];
  const uint16_t s421 = (((uint16_t) s418) << 8) | ((uint16_t) s420);
  const uint32_t s422 = (((uint32_t) s415) << 16) | ((uint32_t) s421);
  const uint32_t s423 = s387 ^ s422;
  const uint32_t s424 = s388 ^ s423;
  const uint32_t s425 = s389 ^ s424;
  const uint32_t s426 = s390 ^ s425;
  const uint16_t s427 = (uint16_t) (s426 >> 16);
  const uint8_t  s428 = (uint8_t) (s427 >> 8);
  const uint8_t  s429 = table0[s428];
  const uint8_t  s430 = (uint8_t) s427;
  const uint8_t  s431 = table0[s430];
  const uint16_t s432 = (((uint16_t) s429) << 8) | ((uint16_t) s431);
  const uint16_t s433 = (uint16_t) s426;
  const uint8_t  s434 = (uint8_t) (s433 >> 8);
  const uint8_t  s435 = table0[s434];
  const uint8_t  s436 = (uint8_t) s433;
  const uint8_t  s437 = table0[s436];
  const uint16_t s438 = (((uint16_t) s435) << 8) | ((uint16_t) s437);
  const uint32_t s439 = (((uint32_t) s432) << 16) | ((uint32_t) s438);
  const uint32_t s440 = s404 ^ s439;
  const uint32_t s441 = s405 ^ s440;
  const uint32_t s442 = s406 ^ s441;
  const uint32_t s443 = s407 ^ s442;
  const uint32_t s444 = (s443 << 8) | (s443 >> 24);
  const uint16_t s445 = (uint16_t) (s444 >> 16);
  const uint8_t  s446 = (uint8_t) (s445 >> 8);
  const uint8_t  s447 = table0[s446];
  const uint8_t  s448 = 32 ^ s447;
  const uint8_t  s449 = (uint8_t) s445;
  const uint8_t  s450 = table0[s449];
  const uint16_t s451 = (((uint16_t) s448) << 8) | ((uint16_t) s450);
  const uint16_t s452 = (uint16_t) s444;
  const uint8_t  s453 = (uint8_t) (s452 >> 8);
  const uint8_t  s454 = table0[s453];
  const uint8_t  s455 = (uint8_t) s452;
  const uint8_t  s456 = table0[s455];
  const uint16_t s457 = (((uint16_t) s454) << 8) | ((uint16_t) s456);
  const uint32_t s458 = (((uint32_t) s451) << 16) | ((uint32_t) s457);
  const uint32_t s459 = s423 ^ s458;
  const uint32_t s460 = s424 ^ s459;
  const uint32_t s461 = s425 ^ s460;
  const uint32_t s462 = s426 ^ s461;
  const uint16_t s463 = (uint16_t) (s462 >> 16);
  const uint8_t  s464 = (uint8_t) (s463 >> 8);
  const uint8_t  s465 = table0[s464];
  const uint8_t  s466 = (uint8_t) s463;
  const uint8_t  s467 = table0[s466];
  const uint16_t s468 = (((uint16_t) s465) << 8) | ((uint16_t) s467);
  const uint16_t s469 = (uint16_t) s462;
  const uint8_t  s470 = (uint8_t) (s469 >> 8);
  const uint8_t  s471 = table0[s470];
  const uint8_t  s472 = (uint8_t) s469;
  const uint8_t  s473 = table0[s472];
  const uint16_t s474 = (((uint16_t) s471) << 8) | ((uint16_t) s473);
  const uint32_t s475 = (((uint32_t) s468) << 16) | ((uint32_t) s474);
  const uint32_t s476 = s440 ^ s475;
  const uint32_t s477 = s441 ^ s476;
  const uint32_t s478 = s442 ^ s477;
  const uint32_t s479 = s443 ^ s478;
  const uint32_t s480 = (s479 << 8) | (s479 >> 24);
  const uint16_t s481 = (uint16_t) (s480 >> 16);
  const uint8_t  s482 = (uint8_t) (s481 >> 8);
  const uint8_t  s483 = table0[s482];
  const uint8_t  s484 = 64 ^ s483;
  const uint8_t  s485 = (uint8_t) s481;
  const uint8_t  s486 = table0[s485];
  const uint16_t s487 = (((uint16_t) s484) << 8) | ((uint16_t) s486);
  const uint16_t s488 = (uint16_t) s480;
  const uint8_t  s489 = (uint8_t) (s488 >> 8);
  const uint8_t  s490 = table0[s489];
  const uint8_t  s491 = (uint8_t) s488;
  const uint8_t  s492 = table0[s491];
  const uint16_t s493 = (((uint16_t) s490) << 8) | ((uint16_t) s492);
  const uint32_t s494 = (((uint32_t) s487) << 16) | ((uint32_t) s493);
  const uint32_t s495 = s459 ^ s494;
  const uint32_t s496 = s460 ^ s495;
  const uint32_t s497 = s461 ^ s496;
  const uint32_t s498 = s462 ^ s497;
  encKS[0] = s0;
  encKS[1] = s1;
  encKS[2] = s2;
  encKS[3] = s3;
  encKS[4] = s4;
  encKS[5] = s5;
  encKS[6] = s6;
  encKS[7] = s7;
  encKS[8] = s279;
  encKS[9] = s280;
  encKS[10] = s281;
  encKS[11] = s282;
  encKS[12] = s296;
  encKS[13] = s297;
  encKS[14] = s298;
  encKS[15] = s299;
  encKS[16] = s315;
  encKS[17] = s316;
  encKS[18] = s317;
  encKS[19] = s318;
  encKS[20] = s332;
  encKS[21] = s333;
  encKS[22] = s334;
  encKS[23] = s335;
  encKS[24] = s351;
  encKS[25] = s352;
  encKS[26] = s353;
  encKS[27] = s354;
  encKS[28] = s368;
  encKS[29] = s369;
  encKS[30] = s370;
  encKS[31] = s371;
  encKS[32] = s387;
  encKS[33] = s388;
  encKS[34] = s389;
  encKS[35] = s390;
  encKS[36] = s404;
  encKS[37] = s405;
  encKS[38] = s406;
  encKS[39] = s407;
  encKS[40] = s423;
  encKS[41] = s424;
  encKS[42] = s425;
  encKS[43] = s426;
  encKS[44] = s440;
  encKS[45] = s441;
  encKS[46] = s442;
  encKS[47] = s443;
  encKS[48] = s459;
  encKS[49] = s460;
  encKS[50] = s461;
  encKS[51] = s462;
  encKS[52] = s476;
  encKS[53] = s477;
  encKS[54] = s478;
  encKS[55] = s479;
  encKS[56] = s495;
  encKS[57] = s496;
  encKS[58] = s497;
  encKS[59] = s498;
}

void aes256_block_enc(const uint32_t *pt,
                      const uint32_t *xkey,
                      uint32_t *ct) {
  const uint32_t s0 = pt[0];
  const uint32_t s1 = pt[1];
  const uint32_t s2 = pt[2];
  const uint32_t s3 = pt[3];
  const uint32_t s4 = xkey[0];
  const uint32_t s5 = xkey[1];
  const uint32_t s6 = xkey[2];
  const uint32_t s7 = xkey[3];
  const uint32_t s8 = xkey[4];
  const uint32_t s9 = xkey[5];
  const uint32_t s10 = xkey[6];
  const uint32_t s11 = xkey[7];
  const uint32_t s12 = xkey[8];
  const uint32_t s13 = xkey[9];
  const uint32_t s14 = xkey[10];
  const uint32_t s15 = xkey[11];
  const uint32_t s16 = xkey[12];
  const uint32_t s17 = xkey[13];
  const uint32_t s18 = xkey[14];
  const uint32_t s19 = xkey[15];
  const uint32_t s20 = xkey[16];
  const uint32_t s21 = xkey[17];
  const uint32_t s22 = xkey[18];
  const uint32_t s23 = xkey[19];
  const uint32_t s24 = xkey[20];
  const uint32_t s25 = xkey[21];
  const uint32_t s26 = xkey[22];
  const uint32_t s27 = xkey[23];
  const uint32_t s28 = xkey[24];
  const uint32_t s29 = xkey[25];
  const uint32_t s30 = xkey[26];
  const uint32_t s31 = xkey[27];
  const uint32_t s32 = xkey[28];
  const uint32_t s33 = xkey[29];
  const uint32_t s34 = xkey[30];
  const uint32_t s35 = xkey[31];
  const uint32_t s36 = xkey[32];
  const uint32_t s37 = xkey[33];
  const uint32_t s38 = xkey[34];
  const uint32_t s39 = xkey[35];
  const uint32_t s40 = xkey[36];
  const uint32_t s41 = xkey[37];
  const uint32_t s42 = xkey[38];
  const uint32_t s43 = xkey[39];
  const uint32_t s44 = xkey[40];
  const uint32_t s45 = xkey[41];
  const uint32_t s46 = xkey[42];
  const uint32_t s47 = xkey[43];
  const uint32_t s48 = xkey[44];
  const uint32_t s49 = xkey[45];
  const uint32_t s50 = xkey[46];
  const uint32_t s51 = xkey[47];
  const uint32_t s52 = xkey[48];
  const uint32_t s53 = xkey[49];
  const uint32_t s54 = xkey[50];
  const uint32_t s55 = xkey[51];
  const uint32_t s56 = xkey[52];
  const uint32_t s57 = xkey[53];
  const uint32_t s58 = xkey[54];
  const uint32_t s59 = xkey[55];
  const uint32_t s60 = xkey[56];
  const uint32_t s61 = xkey[57];
  const uint32_t s62 = xkey[58];
  const uint32_t s63 = xkey[59];
  static const uint8_t table0[] = {
       99, 124, 119, 123, 242, 107, 111, 197,  48,   1, 103,  43, 254,
      215, 171, 118, 202, 130, 201, 125, 250,  89,  71, 240, 173, 212,
      162, 175, 156, 164, 114, 192, 183, 253, 147,  38,  54,  63, 247,
      204,  52, 165, 229, 241, 113, 216,  49,  21,   4, 199,  35, 195,
       24, 150,   5, 154,   7,  18, 128, 226, 235,  39, 178, 117,   9,
      131,  44,  26,  27, 110,  90, 160,  82,  59, 214, 179,  41, 227,
       47, 132,  83, 209,   0, 237,  32, 252, 177,  91, 106, 203, 190,
       57,  74,  76,  88, 207, 208, 239, 170, 251,  67,  77,  51, 133,
       69, 249,   2, 127,  80,  60, 159, 168,  81, 163,  64, 143, 146,
      157,  56, 245, 188, 182, 218,  33,  16, 255, 243, 210, 205,  12,
       19, 236,  95, 151,  68,  23, 196, 167, 126,  61, 100,  93,  25,
      115,  96, 129,  79, 220,  34,  42, 144, 136,  70, 238, 184,  20,
      222,  94,  11, 219, 224,  50,  58,  10,  73,   6,  36,  92, 194,
      211, 172,  98, 145, 149, 228, 121, 231, 200,  55, 109, 141, 213,
       78, 169, 108,  86, 244, 234, 101, 122, 174,   8, 186, 120,  37,
       46,  28, 166, 180, 198, 232, 221, 116,  31,  75, 189, 139, 138,
      112,  62, 181, 102,  72,   3, 246,  14,  97,  53,  87, 185, 134,
      193,  29, 158, 225, 248, 152,  17, 105, 217, 142, 148, 155,  30,
      135, 233, 206,  85,  40, 223, 140, 161, 137,  13, 191, 230,  66,
      104,  65, 153,  45,  15, 176,  84, 187,  22
  };
  static const uint32_t table1[] = {
      0xc66363a5UL, 0xf87c7c84UL, 0xee777799UL, 0xf67b7b8dUL,
      0xfff2f20dUL, 0xd66b6bbdUL, 0xde6f6fb1UL, 0x91c5c554UL,
      0x60303050UL, 0x02010103UL, 0xce6767a9UL, 0x562b2b7dUL,
      0xe7fefe19UL, 0xb5d7d762UL, 0x4dababe6UL, 0xec76769aUL,
      0x8fcaca45UL, 0x1f82829dUL, 0x89c9c940UL, 0xfa7d7d87UL,
      0xeffafa15UL, 0xb25959ebUL, 0x8e4747c9UL, 0xfbf0f00bUL,
      0x41adadecUL, 0xb3d4d467UL, 0x5fa2a2fdUL, 0x45afafeaUL,
      0x239c9cbfUL, 0x53a4a4f7UL, 0xe4727296UL, 0x9bc0c05bUL,
      0x75b7b7c2UL, 0xe1fdfd1cUL, 0x3d9393aeUL, 0x4c26266aUL,
      0x6c36365aUL, 0x7e3f3f41UL, 0xf5f7f702UL, 0x83cccc4fUL,
      0x6834345cUL, 0x51a5a5f4UL, 0xd1e5e534UL, 0xf9f1f108UL,
      0xe2717193UL, 0xabd8d873UL, 0x62313153UL, 0x2a15153fUL,
      0x0804040cUL, 0x95c7c752UL, 0x46232365UL, 0x9dc3c35eUL,
      0x30181828UL, 0x379696a1UL, 0x0a05050fUL, 0x2f9a9ab5UL,
      0x0e070709UL, 0x24121236UL, 0x1b80809bUL, 0xdfe2e23dUL,
      0xcdebeb26UL, 0x4e272769UL, 0x7fb2b2cdUL, 0xea75759fUL,
      0x1209091bUL, 0x1d83839eUL, 0x582c2c74UL, 0x341a1a2eUL,
      0x361b1b2dUL, 0xdc6e6eb2UL, 0xb45a5aeeUL, 0x5ba0a0fbUL,
      0xa45252f6UL, 0x763b3b4dUL, 0xb7d6d661UL, 0x7db3b3ceUL,
      0x5229297bUL, 0xdde3e33eUL, 0x5e2f2f71UL, 0x13848497UL,
      0xa65353f5UL, 0xb9d1d168UL, 0x00000000UL, 0xc1eded2cUL,
      0x40202060UL, 0xe3fcfc1fUL, 0x79b1b1c8UL, 0xb65b5bedUL,
      0xd46a6abeUL, 0x8dcbcb46UL, 0x67bebed9UL, 0x7239394bUL,
      0x944a4adeUL, 0x984c4cd4UL, 0xb05858e8UL, 0x85cfcf4aUL,
      0xbbd0d06bUL, 0xc5efef2aUL, 0x4faaaae5UL, 0xedfbfb16UL,
      0x864343c5UL, 0x9a4d4dd7UL, 0x66333355UL, 0x11858594UL,
      0x8a4545cfUL, 0xe9f9f910UL, 0x04020206UL, 0xfe7f7f81UL,
      0xa05050f0UL, 0x783c3c44UL, 0x259f9fbaUL, 0x4ba8a8e3UL,
      0xa25151f3UL, 0x5da3a3feUL, 0x804040c0UL, 0x058f8f8aUL,
      0x3f9292adUL, 0x219d9dbcUL, 0x70383848UL, 0xf1f5f504UL,
      0x63bcbcdfUL, 0x77b6b6c1UL, 0xafdada75UL, 0x42212163UL,
      0x20101030UL, 0xe5ffff1aUL, 0xfdf3f30eUL, 0xbfd2d26dUL,
      0x81cdcd4cUL, 0x180c0c14UL, 0x26131335UL, 0xc3ecec2fUL,
      0xbe5f5fe1UL, 0x359797a2UL, 0x884444ccUL, 0x2e171739UL,
      0x93c4c457UL, 0x55a7a7f2UL, 0xfc7e7e82UL, 0x7a3d3d47UL,
      0xc86464acUL, 0xba5d5de7UL, 0x3219192bUL, 0xe6737395UL,
      0xc06060a0UL, 0x19818198UL, 0x9e4f4fd1UL, 0xa3dcdc7fUL,
      0x44222266UL, 0x542a2a7eUL, 0x3b9090abUL, 0x0b888883UL,
      0x8c4646caUL, 0xc7eeee29UL, 0x6bb8b8d3UL, 0x2814143cUL,
      0xa7dede79UL, 0xbc5e5ee2UL, 0x160b0b1dUL, 0xaddbdb76UL,
      0xdbe0e03bUL, 0x64323256UL, 0x743a3a4eUL, 0x140a0a1eUL,
      0x924949dbUL, 0x0c06060aUL, 0x4824246cUL, 0xb85c5ce4UL,
      0x9fc2c25dUL, 0xbdd3d36eUL, 0x43acacefUL, 0xc46262a6UL,
      0x399191a8UL, 0x319595a4UL, 0xd3e4e437UL, 0xf279798bUL,
      0xd5e7e732UL, 0x8bc8c843UL, 0x6e373759UL, 0xda6d6db7UL,
      0x018d8d8cUL, 0xb1d5d564UL, 0x9c4e4ed2UL, 0x49a9a9e0UL,
      0xd86c6cb4UL, 0xac5656faUL, 0xf3f4f407UL, 0xcfeaea25UL,
      0xca6565afUL, 0xf47a7a8eUL, 0x47aeaee9UL, 0x10080818UL,
      0x6fbabad5UL, 0xf0787888UL, 0x4a25256fUL, 0x5c2e2e72UL,
      0x381c1c24UL, 0x57a6a6f1UL, 0x73b4b4c7UL, 0x97c6c651UL,
      0xcbe8e823UL, 0xa1dddd7cUL, 0xe874749cUL, 0x3e1f1f21UL,
      0x964b4bddUL, 0x61bdbddcUL, 0x0d8b8b86UL, 0x0f8a8a85UL,
      0xe0707090UL, 0x7c3e3e42UL, 0x71b5b5c4UL, 0xcc6666aaUL,
      0x904848d8UL, 0x06030305UL, 0xf7f6f601UL, 0x1c0e0e12UL,
      0xc26161a3UL, 0x6a35355fUL, 0xae5757f9UL, 0x69b9b9d0UL,
      0x17868691UL, 0x99c1c158UL, 0x3a1d1d27UL, 0x279e9eb9UL,
      0xd9e1e138UL, 0xebf8f813UL, 0x2b9898b3UL, 0x22111133UL,
      0xd26969bbUL, 0xa9d9d970UL, 0x078e8e89UL, 0x339494a7UL,
      0x2d9b9bb6UL, 0x3c1e1e22UL, 0x15878792UL, 0xc9e9e920UL,
      0x87cece49UL, 0xaa5555ffUL, 0x50282878UL, 0xa5dfdf7aUL,
      0x038c8c8fUL, 0x59a1a1f8UL, 0x09898980UL, 0x1a0d0d17UL,
      0x65bfbfdaUL, 0xd7e6e631UL, 0x844242c6UL, 0xd06868b8UL,
      0x824141c3UL, 0x299999b0UL, 0x5a2d2d77UL, 0x1e0f0f11UL,
      0x7bb0b0cbUL, 0xa85454fcUL, 0x6dbbbbd6UL, 0x2c16163aUL
  };
  static const uint32_t table2[] = {
      0xa5c66363UL, 0x84f87c7cUL, 0x99ee7777UL, 0x8df67b7bUL,
      0x0dfff2f2UL, 0xbdd66b6bUL, 0xb1de6f6fUL, 0x5491c5c5UL,
      0x50603030UL, 0x03020101UL, 0xa9ce6767UL, 0x7d562b2bUL,
      0x19e7fefeUL, 0x62b5d7d7UL, 0xe64dababUL, 0x9aec7676UL,
      0x458fcacaUL, 0x9d1f8282UL, 0x4089c9c9UL, 0x87fa7d7dUL,
      0x15effafaUL, 0xebb25959UL, 0xc98e4747UL, 0x0bfbf0f0UL,
      0xec41adadUL, 0x67b3d4d4UL, 0xfd5fa2a2UL, 0xea45afafUL,
      0xbf239c9cUL, 0xf753a4a4UL, 0x96e47272UL, 0x5b9bc0c0UL,
      0xc275b7b7UL, 0x1ce1fdfdUL, 0xae3d9393UL, 0x6a4c2626UL,
      0x5a6c3636UL, 0x417e3f3fUL, 0x02f5f7f7UL, 0x4f83ccccUL,
      0x5c683434UL, 0xf451a5a5UL, 0x34d1e5e5UL, 0x08f9f1f1UL,
      0x93e27171UL, 0x73abd8d8UL, 0x53623131UL, 0x3f2a1515UL,
      0x0c080404UL, 0x5295c7c7UL, 0x65462323UL, 0x5e9dc3c3UL,
      0x28301818UL, 0xa1379696UL, 0x0f0a0505UL, 0xb52f9a9aUL,
      0x090e0707UL, 0x36241212UL, 0x9b1b8080UL, 0x3ddfe2e2UL,
      0x26cdebebUL, 0x694e2727UL, 0xcd7fb2b2UL, 0x9fea7575UL,
      0x1b120909UL, 0x9e1d8383UL, 0x74582c2cUL, 0x2e341a1aUL,
      0x2d361b1bUL, 0xb2dc6e6eUL, 0xeeb45a5aUL, 0xfb5ba0a0UL,
      0xf6a45252UL, 0x4d763b3bUL, 0x61b7d6d6UL, 0xce7db3b3UL,
      0x7b522929UL, 0x3edde3e3UL, 0x715e2f2fUL, 0x97138484UL,
      0xf5a65353UL, 0x68b9d1d1UL, 0x00000000UL, 0x2cc1ededUL,
      0x60402020UL, 0x1fe3fcfcUL, 0xc879b1b1UL, 0xedb65b5bUL,
      0xbed46a6aUL, 0x468dcbcbUL, 0xd967bebeUL, 0x4b723939UL,
      0xde944a4aUL, 0xd4984c4cUL, 0xe8b05858UL, 0x4a85cfcfUL,
      0x6bbbd0d0UL, 0x2ac5efefUL, 0xe54faaaaUL, 0x16edfbfbUL,
      0xc5864343UL, 0xd79a4d4dUL, 0x55663333UL, 0x94118585UL,
      0xcf8a4545UL, 0x10e9f9f9UL, 0x06040202UL, 0x81fe7f7fUL,
      0xf0a05050UL, 0x44783c3cUL, 0xba259f9fUL, 0xe34ba8a8UL,
      0xf3a25151UL, 0xfe5da3a3UL, 0xc0804040UL, 0x8a058f8fUL,
      0xad3f9292UL, 0xbc219d9dUL, 0x48703838UL, 0x04f1f5f5UL,
      0xdf63bcbcUL, 0xc177b6b6UL, 0x75afdadaUL, 0x63422121UL,
      0x30201010UL, 0x1ae5ffffUL, 0x0efdf3f3UL, 0x6dbfd2d2UL,
      0x4c81cdcdUL, 0x14180c0cUL, 0x35261313UL, 0x2fc3ececUL,
      0xe1be5f5fUL, 0xa2359797UL, 0xcc884444UL, 0x392e1717UL,
      0x5793c4c4UL, 0xf255a7a7UL, 0x82fc7e7eUL, 0x477a3d3dUL,
      0xacc86464UL, 0xe7ba5d5dUL, 0x2b321919UL, 0x95e67373UL,
      0xa0c06060UL, 0x98198181UL, 0xd19e4f4fUL, 0x7fa3dcdcUL,
      0x66442222UL, 0x7e542a2aUL, 0xab3b9090UL, 0x830b8888UL,
      0xca8c4646UL, 0x29c7eeeeUL, 0xd36bb8b8UL, 0x3c281414UL,
      0x79a7dedeUL, 0xe2bc5e5eUL, 0x1d160b0bUL, 0x76addbdbUL,
      0x3bdbe0e0UL, 0x56643232UL, 0x4e743a3aUL, 0x1e140a0aUL,
      0xdb924949UL, 0x0a0c0606UL, 0x6c482424UL, 0xe4b85c5cUL,
      0x5d9fc2c2UL, 0x6ebdd3d3UL, 0xef43acacUL, 0xa6c46262UL,
      0xa8399191UL, 0xa4319595UL, 0x37d3e4e4UL, 0x8bf27979UL,
      0x32d5e7e7UL, 0x438bc8c8UL, 0x596e3737UL, 0xb7da6d6dUL,
      0x8c018d8dUL, 0x64b1d5d5UL, 0xd29c4e4eUL, 0xe049a9a9UL,
      0xb4d86c6cUL, 0xfaac5656UL, 0x07f3f4f4UL, 0x25cfeaeaUL,
      0xafca6565UL, 0x8ef47a7aUL, 0xe947aeaeUL, 0x18100808UL,
      0xd56fbabaUL, 0x88f07878UL, 0x6f4a2525UL, 0x725c2e2eUL,
      0x24381c1cUL, 0xf157a6a6UL, 0xc773b4b4UL, 0x5197c6c6UL,
      0x23cbe8e8UL, 0x7ca1ddddUL, 0x9ce87474UL, 0x213e1f1fUL,
      0xdd964b4bUL, 0xdc61bdbdUL, 0x860d8b8bUL, 0x850f8a8aUL,
      0x90e07070UL, 0x427c3e3eUL, 0xc471b5b5UL, 0xaacc6666UL,
      0xd8904848UL, 0x05060303UL, 0x01f7f6f6UL, 0x121c0e0eUL,
      0xa3c26161UL, 0x5f6a3535UL, 0xf9ae5757UL, 0xd069b9b9UL,
      0x91178686UL, 0x5899c1c1UL, 0x273a1d1dUL, 0xb9279e9eUL,
      0x38d9e1e1UL, 0x13ebf8f8UL, 0xb32b9898UL, 0x33221111UL,
      0xbbd26969UL, 0x70a9d9d9UL, 0x89078e8eUL, 0xa7339494UL,
      0xb62d9b9bUL, 0x223c1e1eUL, 0x92158787UL, 0x20c9e9e9UL,
      0x4987ceceUL, 0xffaa5555UL, 0x78502828UL, 0x7aa5dfdfUL,
      0x8f038c8cUL, 0xf859a1a1UL, 0x80098989UL, 0x171a0d0dUL,
      0xda65bfbfUL, 0x31d7e6e6UL, 0xc6844242UL, 0xb8d06868UL,
      0xc3824141UL, 0xb0299999UL, 0x775a2d2dUL, 0x111e0f0fUL,
      0xcb7bb0b0UL, 0xfca85454UL, 0xd66dbbbbUL, 0x3a2c1616UL
  };
  static const uint32_t table3[] = {
      0x63a5c663UL, 0x7c84f87cUL, 0x7799ee77UL, 0x7b8df67bUL,
      0xf20dfff2UL, 0x6bbdd66bUL, 0x6fb1de6fUL, 0xc55491c5UL,
      0x30506030UL, 0x01030201UL, 0x67a9ce67UL, 0x2b7d562bUL,
      0xfe19e7feUL, 0xd762b5d7UL, 0xabe64dabUL, 0x769aec76UL,
      0xca458fcaUL, 0x829d1f82UL, 0xc94089c9UL, 0x7d87fa7dUL,
      0xfa15effaUL, 0x59ebb259UL, 0x47c98e47UL, 0xf00bfbf0UL,
      0xadec41adUL, 0xd467b3d4UL, 0xa2fd5fa2UL, 0xafea45afUL,
      0x9cbf239cUL, 0xa4f753a4UL, 0x7296e472UL, 0xc05b9bc0UL,
      0xb7c275b7UL, 0xfd1ce1fdUL, 0x93ae3d93UL, 0x266a4c26UL,
      0x365a6c36UL, 0x3f417e3fUL, 0xf702f5f7UL, 0xcc4f83ccUL,
      0x345c6834UL, 0xa5f451a5UL, 0xe534d1e5UL, 0xf108f9f1UL,
      0x7193e271UL, 0xd873abd8UL, 0x31536231UL, 0x153f2a15UL,
      0x040c0804UL, 0xc75295c7UL, 0x23654623UL, 0xc35e9dc3UL,
      0x18283018UL, 0x96a13796UL, 0x050f0a05UL, 0x9ab52f9aUL,
      0x07090e07UL, 0x12362412UL, 0x809b1b80UL, 0xe23ddfe2UL,
      0xeb26cdebUL, 0x27694e27UL, 0xb2cd7fb2UL, 0x759fea75UL,
      0x091b1209UL, 0x839e1d83UL, 0x2c74582cUL, 0x1a2e341aUL,
      0x1b2d361bUL, 0x6eb2dc6eUL, 0x5aeeb45aUL, 0xa0fb5ba0UL,
      0x52f6a452UL, 0x3b4d763bUL, 0xd661b7d6UL, 0xb3ce7db3UL,
      0x297b5229UL, 0xe33edde3UL, 0x2f715e2fUL, 0x84971384UL,
      0x53f5a653UL, 0xd168b9d1UL, 0x00000000UL, 0xed2cc1edUL,
      0x20604020UL, 0xfc1fe3fcUL, 0xb1c879b1UL, 0x5bedb65bUL,
      0x6abed46aUL, 0xcb468dcbUL, 0xbed967beUL, 0x394b7239UL,
      0x4ade944aUL, 0x4cd4984cUL, 0x58e8b058UL, 0xcf4a85cfUL,
      0xd06bbbd0UL, 0xef2ac5efUL, 0xaae54faaUL, 0xfb16edfbUL,
      0x43c58643UL, 0x4dd79a4dUL, 0x33556633UL, 0x85941185UL,
      0x45cf8a45UL, 0xf910e9f9UL, 0x02060402UL, 0x7f81fe7fUL,
      0x50f0a050UL, 0x3c44783cUL, 0x9fba259fUL, 0xa8e34ba8UL,
      0x51f3a251UL, 0xa3fe5da3UL, 0x40c08040UL, 0x8f8a058fUL,
      0x92ad3f92UL, 0x9dbc219dUL, 0x38487038UL, 0xf504f1f5UL,
      0xbcdf63bcUL, 0xb6c177b6UL, 0xda75afdaUL, 0x21634221UL,
      0x10302010UL, 0xff1ae5ffUL, 0xf30efdf3UL, 0xd26dbfd2UL,
      0xcd4c81cdUL, 0x0c14180cUL, 0x13352613UL, 0xec2fc3ecUL,
      0x5fe1be5fUL, 0x97a23597UL, 0x44cc8844UL, 0x17392e17UL,
      0xc45793c4UL, 0xa7f255a7UL, 0x7e82fc7eUL, 0x3d477a3dUL,
      0x64acc864UL, 0x5de7ba5dUL, 0x192b3219UL, 0x7395e673UL,
      0x60a0c060UL, 0x81981981UL, 0x4fd19e4fUL, 0xdc7fa3dcUL,
      0x22664422UL, 0x2a7e542aUL, 0x90ab3b90UL, 0x88830b88UL,
      0x46ca8c46UL, 0xee29c7eeUL, 0xb8d36bb8UL, 0x143c2814UL,
      0xde79a7deUL, 0x5ee2bc5eUL, 0x0b1d160bUL, 0xdb76addbUL,
      0xe03bdbe0UL, 0x32566432UL, 0x3a4e743aUL, 0x0a1e140aUL,
      0x49db9249UL, 0x060a0c06UL, 0x246c4824UL, 0x5ce4b85cUL,
      0xc25d9fc2UL, 0xd36ebdd3UL, 0xacef43acUL, 0x62a6c462UL,
      0x91a83991UL, 0x95a43195UL, 0xe437d3e4UL, 0x798bf279UL,
      0xe732d5e7UL, 0xc8438bc8UL, 0x37596e37UL, 0x6db7da6dUL,
      0x8d8c018dUL, 0xd564b1d5UL, 0x4ed29c4eUL, 0xa9e049a9UL,
      0x6cb4d86cUL, 0x56faac56UL, 0xf407f3f4UL, 0xea25cfeaUL,
      0x65afca65UL, 0x7a8ef47aUL, 0xaee947aeUL, 0x08181008UL,
      0xbad56fbaUL, 0x7888f078UL, 0x256f4a25UL, 0x2e725c2eUL,
      0x1c24381cUL, 0xa6f157a6UL, 0xb4c773b4UL, 0xc65197c6UL,
      0xe823cbe8UL, 0xdd7ca1ddUL, 0x749ce874UL, 0x1f213e1fUL,
      0x4bdd964bUL, 0xbddc61bdUL, 0x8b860d8bUL, 0x8a850f8aUL,
      0x7090e070UL, 0x3e427c3eUL, 0xb5c471b5UL, 0x66aacc66UL,
      0x48d89048UL, 0x03050603UL, 0xf601f7f6UL, 0x0e121c0eUL,
      0x61a3c261UL, 0x355f6a35UL, 0x57f9ae57UL, 0xb9d069b9UL,
      0x86911786UL, 0xc15899c1UL, 0x1d273a1dUL, 0x9eb9279eUL,
      0xe138d9e1UL, 0xf813ebf8UL, 0x98b32b98UL, 0x11332211UL,
      0x69bbd269UL, 0xd970a9d9UL, 0x8e89078eUL, 0x94a73394UL,
      0x9bb62d9bUL, 0x1e223c1eUL, 0x87921587UL, 0xe920c9e9UL,
      0xce4987ceUL, 0x55ffaa55UL, 0x28785028UL, 0xdf7aa5dfUL,
      0x8c8f038cUL, 0xa1f859a1UL, 0x89800989UL, 0x0d171a0dUL,
      0xbfda65bfUL, 0xe631d7e6UL, 0x42c68442UL, 0x68b8d068UL,
      0x41c38241UL, 0x99b02999UL, 0x2d775a2dUL, 0x0f111e0fUL,
      0xb0cb7bb0UL, 0x54fca854UL, 0xbbd66dbbUL, 0x163a2c16UL
  };
  static const uint32_t table4[] = {
      0x6363a5c6UL, 0x7c7c84f8UL, 0x777799eeUL, 0x7b7b8df6UL,
      0xf2f20dffUL, 0x6b6bbdd6UL, 0x6f6fb1deUL, 0xc5c55491UL,
      0x30305060UL, 0x01010302UL, 0x6767a9ceUL, 0x2b2b7d56UL,
      0xfefe19e7UL, 0xd7d762b5UL, 0xababe64dUL, 0x76769aecUL,
      0xcaca458fUL, 0x82829d1fUL, 0xc9c94089UL, 0x7d7d87faUL,
      0xfafa15efUL, 0x5959ebb2UL, 0x4747c98eUL, 0xf0f00bfbUL,
      0xadadec41UL, 0xd4d467b3UL, 0xa2a2fd5fUL, 0xafafea45UL,
      0x9c9cbf23UL, 0xa4a4f753UL, 0x727296e4UL, 0xc0c05b9bUL,
      0xb7b7c275UL, 0xfdfd1ce1UL, 0x9393ae3dUL, 0x26266a4cUL,
      0x36365a6cUL, 0x3f3f417eUL, 0xf7f702f5UL, 0xcccc4f83UL,
      0x34345c68UL, 0xa5a5f451UL, 0xe5e534d1UL, 0xf1f108f9UL,
      0x717193e2UL, 0xd8d873abUL, 0x31315362UL, 0x15153f2aUL,
      0x04040c08UL, 0xc7c75295UL, 0x23236546UL, 0xc3c35e9dUL,
      0x18182830UL, 0x9696a137UL, 0x05050f0aUL, 0x9a9ab52fUL,
      0x0707090eUL, 0x12123624UL, 0x80809b1bUL, 0xe2e23ddfUL,
      0xebeb26cdUL, 0x2727694eUL, 0xb2b2cd7fUL, 0x75759feaUL,
      0x09091b12UL, 0x83839e1dUL, 0x2c2c7458UL, 0x1a1a2e34UL,
      0x1b1b2d36UL, 0x6e6eb2dcUL, 0x5a5aeeb4UL, 0xa0a0fb5bUL,
      0x5252f6a4UL, 0x3b3b4d76UL, 0xd6d661b7UL, 0xb3b3ce7dUL,
      0x29297b52UL, 0xe3e33eddUL, 0x2f2f715eUL, 0x84849713UL,
      0x5353f5a6UL, 0xd1d168b9UL, 0x00000000UL, 0xeded2cc1UL,
      0x20206040UL, 0xfcfc1fe3UL, 0xb1b1c879UL, 0x5b5bedb6UL,
      0x6a6abed4UL, 0xcbcb468dUL, 0xbebed967UL, 0x39394b72UL,
      0x4a4ade94UL, 0x4c4cd498UL, 0x5858e8b0UL, 0xcfcf4a85UL,
      0xd0d06bbbUL, 0xefef2ac5UL, 0xaaaae54fUL, 0xfbfb16edUL,
      0x4343c586UL, 0x4d4dd79aUL, 0x33335566UL, 0x85859411UL,
      0x4545cf8aUL, 0xf9f910e9UL, 0x02020604UL, 0x7f7f81feUL,
      0x5050f0a0UL, 0x3c3c4478UL, 0x9f9fba25UL, 0xa8a8e34bUL,
      0x5151f3a2UL, 0xa3a3fe5dUL, 0x4040c080UL, 0x8f8f8a05UL,
      0x9292ad3fUL, 0x9d9dbc21UL, 0x38384870UL, 0xf5f504f1UL,
      0xbcbcdf63UL, 0xb6b6c177UL, 0xdada75afUL, 0x21216342UL,
      0x10103020UL, 0xffff1ae5UL, 0xf3f30efdUL, 0xd2d26dbfUL,
      0xcdcd4c81UL, 0x0c0c1418UL, 0x13133526UL, 0xecec2fc3UL,
      0x5f5fe1beUL, 0x9797a235UL, 0x4444cc88UL, 0x1717392eUL,
      0xc4c45793UL, 0xa7a7f255UL, 0x7e7e82fcUL, 0x3d3d477aUL,
      0x6464acc8UL, 0x5d5de7baUL, 0x19192b32UL, 0x737395e6UL,
      0x6060a0c0UL, 0x81819819UL, 0x4f4fd19eUL, 0xdcdc7fa3UL,
      0x22226644UL, 0x2a2a7e54UL, 0x9090ab3bUL, 0x8888830bUL,
      0x4646ca8cUL, 0xeeee29c7UL, 0xb8b8d36bUL, 0x14143c28UL,
      0xdede79a7UL, 0x5e5ee2bcUL, 0x0b0b1d16UL, 0xdbdb76adUL,
      0xe0e03bdbUL, 0x32325664UL, 0x3a3a4e74UL, 0x0a0a1e14UL,
      0x4949db92UL, 0x06060a0cUL, 0x24246c48UL, 0x5c5ce4b8UL,
      0xc2c25d9fUL, 0xd3d36ebdUL, 0xacacef43UL, 0x6262a6c4UL,
      0x9191a839UL, 0x9595a431UL, 0xe4e437d3UL, 0x79798bf2UL,
      0xe7e732d5UL, 0xc8c8438bUL, 0x3737596eUL, 0x6d6db7daUL,
      0x8d8d8c01UL, 0xd5d564b1UL, 0x4e4ed29cUL, 0xa9a9e049UL,
      0x6c6cb4d8UL, 0x5656faacUL, 0xf4f407f3UL, 0xeaea25cfUL,
      0x6565afcaUL, 0x7a7a8ef4UL, 0xaeaee947UL, 0x08081810UL,
      0xbabad56fUL, 0x787888f0UL, 0x25256f4aUL, 0x2e2e725cUL,
      0x1c1c2438UL, 0xa6a6f157UL, 0xb4b4c773UL, 0xc6c65197UL,
      0xe8e823cbUL, 0xdddd7ca1UL, 0x74749ce8UL, 0x1f1f213eUL,
      0x4b4bdd96UL, 0xbdbddc61UL, 0x8b8b860dUL, 0x8a8a850fUL,
      0x707090e0UL, 0x3e3e427cUL, 0xb5b5c471UL, 0x6666aaccUL,
      0x4848d890UL, 0x03030506UL, 0xf6f601f7UL, 0x0e0e121cUL,
      0x6161a3c2UL, 0x35355f6aUL, 0x5757f9aeUL, 0xb9b9d069UL,
      0x86869117UL, 0xc1c15899UL, 0x1d1d273aUL, 0x9e9eb927UL,
      0xe1e138d9UL, 0xf8f813ebUL, 0x9898b32bUL, 0x11113322UL,
      0x6969bbd2UL, 0xd9d970a9UL, 0x8e8e8907UL, 0x9494a733UL,
      0x9b9bb62dUL, 0x1e1e223cUL, 0x87879215UL, 0xe9e920c9UL,
      0xcece4987UL, 0x5555ffaaUL, 0x28287850UL, 0xdfdf7aa5UL,
      0x8c8c8f03UL, 0xa1a1f859UL, 0x89898009UL, 0x0d0d171aUL,
      0xbfbfda65UL, 0xe6e631d7UL, 0x4242c684UL, 0x6868b8d0UL,
      0x4141c382UL, 0x9999b029UL, 0x2d2d775aUL, 0x0f0f111eUL,
      0xb0b0cb7bUL, 0x5454fca8UL, 0xbbbbd66dUL, 0x16163a2cUL
  };
  const uint32_t s576 = s0 ^ s4;
  const uint16_t s577 = (uint16_t) (s576 >> 16);
  const uint8_t  s578 = (uint8_t) (s577 >> 8);
  const uint32_t s579 = table1[s578];
  const uint32_t s835 = s1 ^ s5;
  const uint16_t s836 = (uint16_t) (s835 >> 16);
  const uint8_t  s837 = (uint8_t) s836;
  const uint32_t s838 = table2[s837];
  const uint32_t s839 = s579 ^ s838;
  const uint32_t s1095 = s2 ^ s6;
  const uint16_t s1096 = (uint16_t) s1095;
  const uint8_t  s1097 = (uint8_t) (s1096 >> 8);
  const uint32_t s1098 = table3[s1097];
  const uint32_t s1099 = s839 ^ s1098;
  const uint32_t s1355 = s3 ^ s7;
  const uint16_t s1356 = (uint16_t) s1355;
  const uint8_t  s1357 = (uint8_t) s1356;
  const uint32_t s1358 = table4[s1357];
  const uint32_t s1359 = s1099 ^ s1358;
  const uint32_t s1360 = s8 ^ s1359;
  const uint16_t s1361 = (uint16_t) (s1360 >> 16);
  const uint8_t  s1362 = (uint8_t) (s1361 >> 8);
  const uint32_t s1363 = table1[s1362];
  const uint8_t  s1364 = (uint8_t) (s836 >> 8);
  const uint32_t s1365 = table1[s1364];
  const uint16_t s1366 = (uint16_t) (s1095 >> 16);
  const uint8_t  s1367 = (uint8_t) s1366;
  const uint32_t s1368 = table2[s1367];
  const uint32_t s1369 = s1365 ^ s1368;
  const uint8_t  s1370 = (uint8_t) (s1356 >> 8);
  const uint32_t s1371 = table3[s1370];
  const uint32_t s1372 = s1369 ^ s1371;
  const uint16_t s1373 = (uint16_t) s576;
  const uint8_t  s1374 = (uint8_t) s1373;
  const uint32_t s1375 = table4[s1374];
  const uint32_t s1376 = s1372 ^ s1375;
  const uint32_t s1377 = s9 ^ s1376;
  const uint16_t s1378 = (uint16_t) (s1377 >> 16);
  const uint8_t  s1379 = (uint8_t) s1378;
  const uint32_t s1380 = table2[s1379];
  const uint32_t s1381 = s1363 ^ s1380;
  const uint8_t  s1382 = (uint8_t) (s1366 >> 8);
  const uint32_t s1383 = table1[s1382];
  const uint16_t s1384 = (uint16_t) (s1355 >> 16);
  const uint8_t  s1385 = (uint8_t) s1384;
  const uint32_t s1386 = table2[s1385];
  const uint32_t s1387 = s1383 ^ s1386;
  const uint8_t  s1388 = (uint8_t) (s1373 >> 8);
  const uint32_t s1389 = table3[s1388];
  const uint32_t s1390 = s1387 ^ s1389;
  const uint16_t s1391 = (uint16_t) s835;
  const uint8_t  s1392 = (uint8_t) s1391;
  const uint32_t s1393 = table4[s1392];
  const uint32_t s1394 = s1390 ^ s1393;
  const uint32_t s1395 = s10 ^ s1394;
  const uint16_t s1396 = (uint16_t) s1395;
  const uint8_t  s1397 = (uint8_t) (s1396 >> 8);
  const uint32_t s1398 = table3[s1397];
  const uint32_t s1399 = s1381 ^ s1398;
  const uint8_t  s1400 = (uint8_t) (s1384 >> 8);
  const uint32_t s1401 = table1[s1400];
  const uint8_t  s1402 = (uint8_t) s577;
  const uint32_t s1403 = table2[s1402];
  const uint32_t s1404 = s1401 ^ s1403;
  const uint8_t  s1405 = (uint8_t) (s1391 >> 8);
  const uint32_t s1406 = table3[s1405];
  const uint32_t s1407 = s1404 ^ s1406;
  const uint8_t  s1408 = (uint8_t) s1096;
  const uint32_t s1409 = table4[s1408];
  const uint32_t s1410 = s1407 ^ s1409;
  const uint32_t s1411 = s11 ^ s1410;
  const uint16_t s1412 = (uint16_t) s1411;
  const uint8_t  s1413 = (uint8_t) s1412;
  const uint32_t s1414 = table4[s1413];
  const uint32_t s1415 = s1399 ^ s1414;
  const uint32_t s1416 = s12 ^ s1415;
  const uint16_t s1417 = (uint16_t) (s1416 >> 16);
  const uint8_t  s1418 = (uint8_t) (s1417 >> 8);
  const uint32_t s1419 = table1[s1418];
  const uint8_t  s1420 = (uint8_t) (s1378 >> 8);
  const uint32_t s1421 = table1[s1420];
  const uint16_t s1422 = (uint16_t) (s1395 >> 16);
  const uint8_t  s1423 = (uint8_t) s1422;
  const uint32_t s1424 = table2[s1423];
  const uint32_t s1425 = s1421 ^ s1424;
  const uint8_t  s1426 = (uint8_t) (s1412 >> 8);
  const uint32_t s1427 = table3[s1426];
  const uint32_t s1428 = s1425 ^ s1427;
  const uint16_t s1429 = (uint16_t) s1360;
  const uint8_t  s1430 = (uint8_t) s1429;
  const uint32_t s1431 = table4[s1430];
  const uint32_t s1432 = s1428 ^ s1431;
  const uint32_t s1433 = s13 ^ s1432;
  const uint16_t s1434 = (uint16_t) (s1433 >> 16);
  const uint8_t  s1435 = (uint8_t) s1434;
  const uint32_t s1436 = table2[s1435];
  const uint32_t s1437 = s1419 ^ s1436;
  const uint8_t  s1438 = (uint8_t) (s1422 >> 8);
  const uint32_t s1439 = table1[s1438];
  const uint16_t s1440 = (uint16_t) (s1411 >> 16);
  const uint8_t  s1441 = (uint8_t) s1440;
  const uint32_t s1442 = table2[s1441];
  const uint32_t s1443 = s1439 ^ s1442;
  const uint8_t  s1444 = (uint8_t) (s1429 >> 8);
  const uint32_t s1445 = table3[s1444];
  const uint32_t s1446 = s1443 ^ s1445;
  const uint16_t s1447 = (uint16_t) s1377;
  const uint8_t  s1448 = (uint8_t) s1447;
  const uint32_t s1449 = table4[s1448];
  const uint32_t s1450 = s1446 ^ s1449;
  const uint32_t s1451 = s14 ^ s1450;
  const uint16_t s1452 = (uint16_t) s1451;
  const uint8_t  s1453 = (uint8_t) (s1452 >> 8);
  const uint32_t s1454 = table3[s1453];
  const uint32_t s1455 = s1437 ^ s1454;
  const uint8_t  s1456 = (uint8_t) (s1440 >> 8);
  const uint32_t s1457 = table1[s1456];
  const uint8_t  s1458 = (uint8_t) s1361;
  const uint32_t s1459 = table2[s1458];
  const uint32_t s1460 = s1457 ^ s1459;
  const uint8_t  s1461 = (uint8_t) (s1447 >> 8);
  const uint32_t s1462 = table3[s1461];
  const uint32_t s1463 = s1460 ^ s1462;
  const uint8_t  s1464 = (uint8_t) s1396;
  const uint32_t s1465 = table4[s1464];
  const uint32_t s1466 = s1463 ^ s1465;
  const uint32_t s1467 = s15 ^ s1466;
  const uint16_t s1468 = (uint16_t) s1467;
  const uint8_t  s1469 = (uint8_t) s1468;
  const uint32_t s1470 = table4[s1469];
  const uint32_t s1471 = s1455 ^ s1470;
  const uint32_t s1472 = s16 ^ s1471;
  const uint16_t s1473 = (uint16_t) (s1472 >> 16);
  const uint8_t  s1474 = (uint8_t) (s1473 >> 8);
  const uint32_t s1475 = table1[s1474];
  const uint8_t  s1476 = (uint8_t) (s1434 >> 8);
  const uint32_t s1477 = table1[s1476];
  const uint16_t s1478 = (uint16_t) (s1451 >> 16);
  const uint8_t  s1479 = (uint8_t) s1478;
  const uint32_t s1480 = table2[s1479];
  const uint32_t s1481 = s1477 ^ s1480;
  const uint8_t  s1482 = (uint8_t) (s1468 >> 8);
  const uint32_t s1483 = table3[s1482];
  const uint32_t s1484 = s1481 ^ s1483;
  const uint16_t s1485 = (uint16_t) s1416;
  const uint8_t  s1486 = (uint8_t) s1485;
  const uint32_t s1487 = table4[s1486];
  const uint32_t s1488 = s1484 ^ s1487;
  const uint32_t s1489 = s17 ^ s1488;
  const uint16_t s1490 = (uint16_t) (s1489 >> 16);
  const uint8_t  s1491 = (uint8_t) s1490;
  const uint32_t s1492 = table2[s1491];
  const uint32_t s1493 = s1475 ^ s1492;
  const uint8_t  s1494 = (uint8_t) (s1478 >> 8);
  const uint32_t s1495 = table1[s1494];
  const uint16_t s1496 = (uint16_t) (s1467 >> 16);
  const uint8_t  s1497 = (uint8_t) s1496;
  const uint32_t s1498 = table2[s1497];
  const uint32_t s1499 = s1495 ^ s1498;
  const uint8_t  s1500 = (uint8_t) (s1485 >> 8);
  const uint32_t s1501 = table3[s1500];
  const uint32_t s1502 = s1499 ^ s1501;
  const uint16_t s1503 = (uint16_t) s1433;
  const uint8_t  s1504 = (uint8_t) s1503;
  const uint32_t s1505 = table4[s1504];
  const uint32_t s1506 = s1502 ^ s1505;
  const uint32_t s1507 = s18 ^ s1506;
  const uint16_t s1508 = (uint16_t) s1507;
  const uint8_t  s1509 = (uint8_t) (s1508 >> 8);
  const uint32_t s1510 = table3[s1509];
  const uint32_t s1511 = s1493 ^ s1510;
  const uint8_t  s1512 = (uint8_t) (s1496 >> 8);
  const uint32_t s1513 = table1[s1512];
  const uint8_t  s1514 = (uint8_t) s1417;
  const uint32_t s1515 = table2[s1514];
  const uint32_t s1516 = s1513 ^ s1515;
  const uint8_t  s1517 = (uint8_t) (s1503 >> 8);
  const uint32_t s1518 = table3[s1517];
  const uint32_t s1519 = s1516 ^ s1518;
  const uint8_t  s1520 = (uint8_t) s1452;
  const uint32_t s1521 = table4[s1520];
  const uint32_t s1522 = s1519 ^ s1521;
  const uint32_t s1523 = s19 ^ s1522;
  const uint16_t s1524 = (uint16_t) s1523;
  const uint8_t  s1525 = (uint8_t) s1524;
  const uint32_t s1526 = table4[s1525];
  const uint32_t s1527 = s1511 ^ s1526;
  const uint32_t s1528 = s20 ^ s1527;
  const uint16_t s1529 = (uint16_t) (s1528 >> 16);
  const uint8_t  s1530 = (uint8_t) (s1529 >> 8);
  const uint32_t s1531 = table1[s1530];
  const uint8_t  s1532 = (uint8_t) (s1490 >> 8);
  const uint32_t s1533 = table1[s1532];
  const uint16_t s1534 = (uint16_t) (s1507 >> 16);
  const uint8_t  s1535 = (uint8_t) s1534;
  const uint32_t s1536 = table2[s1535];
  const uint32_t s1537 = s1533 ^ s1536;
  const uint8_t  s1538 = (uint8_t) (s1524 >> 8);
  const uint32_t s1539 = table3[s1538];
  const uint32_t s1540 = s1537 ^ s1539;
  const uint16_t s1541 = (uint16_t) s1472;
  const uint8_t  s1542 = (uint8_t) s1541;
  const uint32_t s1543 = table4[s1542];
  const uint32_t s1544 = s1540 ^ s1543;
  const uint32_t s1545 = s21 ^ s1544;
  const uint16_t s1546 = (uint16_t) (s1545 >> 16);
  const uint8_t  s1547 = (uint8_t) s1546;
  const uint32_t s1548 = table2[s1547];
  const uint32_t s1549 = s1531 ^ s1548;
  const uint8_t  s1550 = (uint8_t) (s1534 >> 8);
  const uint32_t s1551 = table1[s1550];
  const uint16_t s1552 = (uint16_t) (s1523 >> 16);
  const uint8_t  s1553 = (uint8_t) s1552;
  const uint32_t s1554 = table2[s1553];
  const uint32_t s1555 = s1551 ^ s1554;
  const uint8_t  s1556 = (uint8_t) (s1541 >> 8);
  const uint32_t s1557 = table3[s1556];
  const uint32_t s1558 = s1555 ^ s1557;
  const uint16_t s1559 = (uint16_t) s1489;
  const uint8_t  s1560 = (uint8_t) s1559;
  const uint32_t s1561 = table4[s1560];
  const uint32_t s1562 = s1558 ^ s1561;
  const uint32_t s1563 = s22 ^ s1562;
  const uint16_t s1564 = (uint16_t) s1563;
  const uint8_t  s1565 = (uint8_t) (s1564 >> 8);
  const uint32_t s1566 = table3[s1565];
  const uint32_t s1567 = s1549 ^ s1566;
  const uint8_t  s1568 = (uint8_t) (s1552 >> 8);
  const uint32_t s1569 = table1[s1568];
  const uint8_t  s1570 = (uint8_t) s1473;
  const uint32_t s1571 = table2[s1570];
  const uint32_t s1572 = s1569 ^ s1571;
  const uint8_t  s1573 = (uint8_t) (s1559 >> 8);
  const uint32_t s1574 = table3[s1573];
  const uint32_t s1575 = s1572 ^ s1574;
  const uint8_t  s1576 = (uint8_t) s1508;
  const uint32_t s1577 = table4[s1576];
  const uint32_t s1578 = s1575 ^ s1577;
  const uint32_t s1579 = s23 ^ s1578;
  const uint16_t s1580 = (uint16_t) s1579;
  const uint8_t  s1581 = (uint8_t) s1580;
  const uint32_t s1582 = table4[s1581];
  const uint32_t s1583 = s1567 ^ s1582;
  const uint32_t s1584 = s24 ^ s1583;
  const uint16_t s1585 = (uint16_t) (s1584 >> 16);
  const uint8_t  s1586 = (uint8_t) (s1585 >> 8);
  const uint32_t s1587 = table1[s1586];
  const uint8_t  s1588 = (uint8_t) (s1546 >> 8);
  const uint32_t s1589 = table1[s1588];
  const uint16_t s1590 = (uint16_t) (s1563 >> 16);
  const uint8_t  s1591 = (uint8_t) s1590;
  const uint32_t s1592 = table2[s1591];
  const uint32_t s1593 = s1589 ^ s1592;
  const uint8_t  s1594 = (uint8_t) (s1580 >> 8);
  const uint32_t s1595 = table3[s1594];
  const uint32_t s1596 = s1593 ^ s1595;
  const uint16_t s1597 = (uint16_t) s1528;
  const uint8_t  s1598 = (uint8_t) s1597;
  const uint32_t s1599 = table4[s1598];
  const uint32_t s1600 = s1596 ^ s1599;
  const uint32_t s1601 = s25 ^ s1600;
  const uint16_t s1602 = (uint16_t) (s1601 >> 16);
  const uint8_t  s1603 = (uint8_t) s1602;
  const uint32_t s1604 = table2[s1603];
  const uint32_t s1605 = s1587 ^ s1604;
  const uint8_t  s1606 = (uint8_t) (s1590 >> 8);
  const uint32_t s1607 = table1[s1606];
  const uint16_t s1608 = (uint16_t) (s1579 >> 16);
  const uint8_t  s1609 = (uint8_t) s1608;
  const uint32_t s1610 = table2[s1609];
  const uint32_t s1611 = s1607 ^ s1610;
  const uint8_t  s1612 = (uint8_t) (s1597 >> 8);
  const uint32_t s1613 = table3[s1612];
  const uint32_t s1614 = s1611 ^ s1613;
  const uint16_t s1615 = (uint16_t) s1545;
  const uint8_t  s1616 = (uint8_t) s1615;
  const uint32_t s1617 = table4[s1616];
  const uint32_t s1618 = s1614 ^ s1617;
  const uint32_t s1619 = s26 ^ s1618;
  const uint16_t s1620 = (uint16_t) s1619;
  const uint8_t  s1621 = (uint8_t) (s1620 >> 8);
  const uint32_t s1622 = table3[s1621];
  const uint32_t s1623 = s1605 ^ s1622;
  const uint8_t  s1624 = (uint8_t) (s1608 >> 8);
  const uint32_t s1625 = table1[s1624];
  const uint8_t  s1626 = (uint8_t) s1529;
  const uint32_t s1627 = table2[s1626];
  const uint32_t s1628 = s1625 ^ s1627;
  const uint8_t  s1629 = (uint8_t) (s1615 >> 8);
  const uint32_t s1630 = table3[s1629];
  const uint32_t s1631 = s1628 ^ s1630;
  const uint8_t  s1632 = (uint8_t) s1564;
  const uint32_t s1633 = table4[s1632];
  const uint32_t s1634 = s1631 ^ s1633;
  const uint32_t s1635 = s27 ^ s1634;
  const uint16_t s1636 = (uint16_t) s1635;
  const uint8_t  s1637 = (uint8_t) s1636;
  const uint32_t s1638 = table4[s1637];
  const uint32_t s1639 = s1623 ^ s1638;
  const uint32_t s1640 = s28 ^ s1639;
  const uint16_t s1641 = (uint16_t) (s1640 >> 16);
  const uint8_t  s1642 = (uint8_t) (s1641 >> 8);
  const uint32_t s1643 = table1[s1642];
  const uint8_t  s1644 = (uint8_t) (s1602 >> 8);
  const uint32_t s1645 = table1[s1644];
  const uint16_t s1646 = (uint16_t) (s1619 >> 16);
  const uint8_t  s1647 = (uint8_t) s1646;
  const uint32_t s1648 = table2[s1647];
  const uint32_t s1649 = s1645 ^ s1648;
  const uint8_t  s1650 = (uint8_t) (s1636 >> 8);
  const uint32_t s1651 = table3[s1650];
  const uint32_t s1652 = s1649 ^ s1651;
  const uint16_t s1653 = (uint16_t) s1584;
  const uint8_t  s1654 = (uint8_t) s1653;
  const uint32_t s1655 = table4[s1654];
  const uint32_t s1656 = s1652 ^ s1655;
  const uint32_t s1657 = s29 ^ s1656;
  const uint16_t s1658 = (uint16_t) (s1657 >> 16);
  const uint8_t  s1659 = (uint8_t) s1658;
  const uint32_t s1660 = table2[s1659];
  const uint32_t s1661 = s1643 ^ s1660;
  const uint8_t  s1662 = (uint8_t) (s1646 >> 8);
  const uint32_t s1663 = table1[s1662];
  const uint16_t s1664 = (uint16_t) (s1635 >> 16);
  const uint8_t  s1665 = (uint8_t) s1664;
  const uint32_t s1666 = table2[s1665];
  const uint32_t s1667 = s1663 ^ s1666;
  const uint8_t  s1668 = (uint8_t) (s1653 >> 8);
  const uint32_t s1669 = table3[s1668];
  const uint32_t s1670 = s1667 ^ s1669;
  const uint16_t s1671 = (uint16_t) s1601;
  const uint8_t  s1672 = (uint8_t) s1671;
  const uint32_t s1673 = table4[s1672];
  const uint32_t s1674 = s1670 ^ s1673;
  const uint32_t s1675 = s30 ^ s1674;
  const uint16_t s1676 = (uint16_t) s1675;
  const uint8_t  s1677 = (uint8_t) (s1676 >> 8);
  const uint32_t s1678 = table3[s1677];
  const uint32_t s1679 = s1661 ^ s1678;
  const uint8_t  s1680 = (uint8_t) (s1664 >> 8);
  const uint32_t s1681 = table1[s1680];
  const uint8_t  s1682 = (uint8_t) s1585;
  const uint32_t s1683 = table2[s1682];
  const uint32_t s1684 = s1681 ^ s1683;
  const uint8_t  s1685 = (uint8_t) (s1671 >> 8);
  const uint32_t s1686 = table3[s1685];
  const uint32_t s1687 = s1684 ^ s1686;
  const uint8_t  s1688 = (uint8_t) s1620;
  const uint32_t s1689 = table4[s1688];
  const uint32_t s1690 = s1687 ^ s1689;
  const uint32_t s1691 = s31 ^ s1690;
  const uint16_t s1692 = (uint16_t) s1691;
  const uint8_t  s1693 = (uint8_t) s1692;
  const uint32_t s1694 = table4[s1693];
  const uint32_t s1695 = s1679 ^ s1694;
  const uint32_t s1696 = s32 ^ s1695;
  const uint16_t s1697 = (uint16_t) (s1696 >> 16);
  const uint8_t  s1698 = (uint8_t) (s1697 >> 8);
  const uint32_t s1699 = table1[s1698];
  const uint8_t  s1700 = (uint8_t) (s1658 >> 8);
  const uint32_t s1701 = table1[s1700];
  const uint16_t s1702 = (uint16_t) (s1675 >> 16);
  const uint8_t  s1703 = (uint8_t) s1702;
  const uint32_t s1704 = table2[s1703];
  const uint32_t s1705 = s1701 ^ s1704;
  const uint8_t  s1706 = (uint8_t) (s1692 >> 8);
  const uint32_t s1707 = table3[s1706];
  const uint32_t s1708 = s1705 ^ s1707;
  const uint16_t s1709 = (uint16_t) s1640;
  const uint8_t  s1710 = (uint8_t) s1709;
  const uint32_t s1711 = table4[s1710];
  const uint32_t s1712 = s1708 ^ s1711;
  const uint32_t s1713 = s33 ^ s1712;
  const uint16_t s1714 = (uint16_t) (s1713 >> 16);
  const uint8_t  s1715 = (uint8_t) s1714;
  const uint32_t s1716 = table2[s1715];
  const uint32_t s1717 = s1699 ^ s1716;
  const uint8_t  s1718 = (uint8_t) (s1702 >> 8);
  const uint32_t s1719 = table1[s1718];
  const uint16_t s1720 = (uint16_t) (s1691 >> 16);
  const uint8_t  s1721 = (uint8_t) s1720;
  const uint32_t s1722 = table2[s1721];
  const uint32_t s1723 = s1719 ^ s1722;
  const uint8_t  s1724 = (uint8_t) (s1709 >> 8);
  const uint32_t s1725 = table3[s1724];
  const uint32_t s1726 = s1723 ^ s1725;
  const uint16_t s1727 = (uint16_t) s1657;
  const uint8_t  s1728 = (uint8_t) s1727;
  const uint32_t s1729 = table4[s1728];
  const uint32_t s1730 = s1726 ^ s1729;
  const uint32_t s1731 = s34 ^ s1730;
  const uint16_t s1732 = (uint16_t) s1731;
  const uint8_t  s1733 = (uint8_t) (s1732 >> 8);
  const uint32_t s1734 = table3[s1733];
  const uint32_t s1735 = s1717 ^ s1734;
  const uint8_t  s1736 = (uint8_t) (s1720 >> 8);
  const uint32_t s1737 = table1[s1736];
  const uint8_t  s1738 = (uint8_t) s1641;
  const uint32_t s1739 = table2[s1738];
  const uint32_t s1740 = s1737 ^ s1739;
  const uint8_t  s1741 = (uint8_t) (s1727 >> 8);
  const uint32_t s1742 = table3[s1741];
  const uint32_t s1743 = s1740 ^ s1742;
  const uint8_t  s1744 = (uint8_t) s1676;
  const uint32_t s1745 = table4[s1744];
  const uint32_t s1746 = s1743 ^ s1745;
  const uint32_t s1747 = s35 ^ s1746;
  const uint16_t s1748 = (uint16_t) s1747;
  const uint8_t  s1749 = (uint8_t) s1748;
  const uint32_t s1750 = table4[s1749];
  const uint32_t s1751 = s1735 ^ s1750;
  const uint32_t s1752 = s36 ^ s1751;
  const uint16_t s1753 = (uint16_t) (s1752 >> 16);
  const uint8_t  s1754 = (uint8_t) (s1753 >> 8);
  const uint32_t s1755 = table1[s1754];
  const uint8_t  s1756 = (uint8_t) (s1714 >> 8);
  const uint32_t s1757 = table1[s1756];
  const uint16_t s1758 = (uint16_t) (s1731 >> 16);
  const uint8_t  s1759 = (uint8_t) s1758;
  const uint32_t s1760 = table2[s1759];
  const uint32_t s1761 = s1757 ^ s1760;
  const uint8_t  s1762 = (uint8_t) (s1748 >> 8);
  const uint32_t s1763 = table3[s1762];
  const uint32_t s1764 = s1761 ^ s1763;
  const uint16_t s1765 = (uint16_t) s1696;
  const uint8_t  s1766 = (uint8_t) s1765;
  const uint32_t s1767 = table4[s1766];
  const uint32_t s1768 = s1764 ^ s1767;
  const uint32_t s1769 = s37 ^ s1768;
  const uint16_t s1770 = (uint16_t) (s1769 >> 16);
  const uint8_t  s1771 = (uint8_t) s1770;
  const uint32_t s1772 = table2[s1771];
  const uint32_t s1773 = s1755 ^ s1772;
  const uint8_t  s1774 = (uint8_t) (s1758 >> 8);
  const uint32_t s1775 = table1[s1774];
  const uint16_t s1776 = (uint16_t) (s1747 >> 16);
  const uint8_t  s1777 = (uint8_t) s1776;
  const uint32_t s1778 = table2[s1777];
  const uint32_t s1779 = s1775 ^ s1778;
  const uint8_t  s1780 = (uint8_t) (s1765 >> 8);
  const uint32_t s1781 = table3[s1780];
  const uint32_t s1782 = s1779 ^ s1781;
  const uint16_t s1783 = (uint16_t) s1713;
  const uint8_t  s1784 = (uint8_t) s1783;
  const uint32_t s1785 = table4[s1784];
  const uint32_t s1786 = s1782 ^ s1785;
  const uint32_t s1787 = s38 ^ s1786;
  const uint16_t s1788 = (uint16_t) s1787;
  const uint8_t  s1789 = (uint8_t) (s1788 >> 8);
  const uint32_t s1790 = table3[s1789];
  const uint32_t s1791 = s1773 ^ s1790;
  const uint8_t  s1792 = (uint8_t) (s1776 >> 8);
  const uint32_t s1793 = table1[s1792];
  const uint8_t  s1794 = (uint8_t) s1697;
  const uint32_t s1795 = table2[s1794];
  const uint32_t s1796 = s1793 ^ s1795;
  const uint8_t  s1797 = (uint8_t) (s1783 >> 8);
  const uint32_t s1798 = table3[s1797];
  const uint32_t s1799 = s1796 ^ s1798;
  const uint8_t  s1800 = (uint8_t) s1732;
  const uint32_t s1801 = table4[s1800];
  const uint32_t s1802 = s1799 ^ s1801;
  const uint32_t s1803 = s39 ^ s1802;
  const uint16_t s1804 = (uint16_t) s1803;
  const uint8_t  s1805 = (uint8_t) s1804;
  const uint32_t s1806 = table4[s1805];
  const uint32_t s1807 = s1791 ^ s1806;
  const uint32_t s1808 = s40 ^ s1807;
  const uint16_t s1809 = (uint16_t) (s1808 >> 16);
  const uint8_t  s1810 = (uint8_t) (s1809 >> 8);
  const uint32_t s1811 = table1[s1810];
  const uint8_t  s1812 = (uint8_t) (s1770 >> 8);
  const uint32_t s1813 = table1[s1812];
  const uint16_t s1814 = (uint16_t) (s1787 >> 16);
  const uint8_t  s1815 = (uint8_t) s1814;
  const uint32_t s1816 = table2[s1815];
  const uint32_t s1817 = s1813 ^ s1816;
  const uint8_t  s1818 = (uint8_t) (s1804 >> 8);
  const uint32_t s1819 = table3[s1818];
  const uint32_t s1820 = s1817 ^ s1819;
  const uint16_t s1821 = (uint16_t) s1752;
  const uint8_t  s1822 = (uint8_t) s1821;
  const uint32_t s1823 = table4[s1822];
  const uint32_t s1824 = s1820 ^ s1823;
  const uint32_t s1825 = s41 ^ s1824;
  const uint16_t s1826 = (uint16_t) (s1825 >> 16);
  const uint8_t  s1827 = (uint8_t) s1826;
  const uint32_t s1828 = table2[s1827];
  const uint32_t s1829 = s1811 ^ s1828;
  const uint8_t  s1830 = (uint8_t) (s1814 >> 8);
  const uint32_t s1831 = table1[s1830];
  const uint16_t s1832 = (uint16_t) (s1803 >> 16);
  const uint8_t  s1833 = (uint8_t) s1832;
  const uint32_t s1834 = table2[s1833];
  const uint32_t s1835 = s1831 ^ s1834;
  const uint8_t  s1836 = (uint8_t) (s1821 >> 8);
  const uint32_t s1837 = table3[s1836];
  const uint32_t s1838 = s1835 ^ s1837;
  const uint16_t s1839 = (uint16_t) s1769;
  const uint8_t  s1840 = (uint8_t) s1839;
  const uint32_t s1841 = table4[s1840];
  const uint32_t s1842 = s1838 ^ s1841;
  const uint32_t s1843 = s42 ^ s1842;
  const uint16_t s1844 = (uint16_t) s1843;
  const uint8_t  s1845 = (uint8_t) (s1844 >> 8);
  const uint32_t s1846 = table3[s1845];
  const uint32_t s1847 = s1829 ^ s1846;
  const uint8_t  s1848 = (uint8_t) (s1832 >> 8);
  const uint32_t s1849 = table1[s1848];
  const uint8_t  s1850 = (uint8_t) s1753;
  const uint32_t s1851 = table2[s1850];
  const uint32_t s1852 = s1849 ^ s1851;
  const uint8_t  s1853 = (uint8_t) (s1839 >> 8);
  const uint32_t s1854 = table3[s1853];
  const uint32_t s1855 = s1852 ^ s1854;
  const uint8_t  s1856 = (uint8_t) s1788;
  const uint32_t s1857 = table4[s1856];
  const uint32_t s1858 = s1855 ^ s1857;
  const uint32_t s1859 = s43 ^ s1858;
  const uint16_t s1860 = (uint16_t) s1859;
  const uint8_t  s1861 = (uint8_t) s1860;
  const uint32_t s1862 = table4[s1861];
  const uint32_t s1863 = s1847 ^ s1862;
  const uint32_t s1864 = s44 ^ s1863;
  const uint16_t s1865 = (uint16_t) (s1864 >> 16);
  const uint8_t  s1866 = (uint8_t) (s1865 >> 8);
  const uint32_t s1867 = table1[s1866];
  const uint8_t  s1868 = (uint8_t) (s1826 >> 8);
  const uint32_t s1869 = table1[s1868];
  const uint16_t s1870 = (uint16_t) (s1843 >> 16);
  const uint8_t  s1871 = (uint8_t) s1870;
  const uint32_t s1872 = table2[s1871];
  const uint32_t s1873 = s1869 ^ s1872;
  const uint8_t  s1874 = (uint8_t) (s1860 >> 8);
  const uint32_t s1875 = table3[s1874];
  const uint32_t s1876 = s1873 ^ s1875;
  const uint16_t s1877 = (uint16_t) s1808;
  const uint8_t  s1878 = (uint8_t) s1877;
  const uint32_t s1879 = table4[s1878];
  const uint32_t s1880 = s1876 ^ s1879;
  const uint32_t s1881 = s45 ^ s1880;
  const uint16_t s1882 = (uint16_t) (s1881 >> 16);
  const uint8_t  s1883 = (uint8_t) s1882;
  const uint32_t s1884 = table2[s1883];
  const uint32_t s1885 = s1867 ^ s1884;
  const uint8_t  s1886 = (uint8_t) (s1870 >> 8);
  const uint32_t s1887 = table1[s1886];
  const uint16_t s1888 = (uint16_t) (s1859 >> 16);
  const uint8_t  s1889 = (uint8_t) s1888;
  const uint32_t s1890 = table2[s1889];
  const uint32_t s1891 = s1887 ^ s1890;
  const uint8_t  s1892 = (uint8_t) (s1877 >> 8);
  const uint32_t s1893 = table3[s1892];
  const uint32_t s1894 = s1891 ^ s1893;
  const uint16_t s1895 = (uint16_t) s1825;
  const uint8_t  s1896 = (uint8_t) s1895;
  const uint32_t s1897 = table4[s1896];
  const uint32_t s1898 = s1894 ^ s1897;
  const uint32_t s1899 = s46 ^ s1898;
  const uint16_t s1900 = (uint16_t) s1899;
  const uint8_t  s1901 = (uint8_t) (s1900 >> 8);
  const uint32_t s1902 = table3[s1901];
  const uint32_t s1903 = s1885 ^ s1902;
  const uint8_t  s1904 = (uint8_t) (s1888 >> 8);
  const uint32_t s1905 = table1[s1904];
  const uint8_t  s1906 = (uint8_t) s1809;
  const uint32_t s1907 = table2[s1906];
  const uint32_t s1908 = s1905 ^ s1907;
  const uint8_t  s1909 = (uint8_t) (s1895 >> 8);
  const uint32_t s1910 = table3[s1909];
  const uint32_t s1911 = s1908 ^ s1910;
  const uint8_t  s1912 = (uint8_t) s1844;
  const uint32_t s1913 = table4[s1912];
  const uint32_t s1914 = s1911 ^ s1913;
  const uint32_t s1915 = s47 ^ s1914;
  const uint16_t s1916 = (uint16_t) s1915;
  const uint8_t  s1917 = (uint8_t) s1916;
  const uint32_t s1918 = table4[s1917];
  const uint32_t s1919 = s1903 ^ s1918;
  const uint32_t s1920 = s48 ^ s1919;
  const uint16_t s1921 = (uint16_t) (s1920 >> 16);
  const uint8_t  s1922 = (uint8_t) (s1921 >> 8);
  const uint32_t s1923 = table1[s1922];
  const uint8_t  s1924 = (uint8_t) (s1882 >> 8);
  const uint32_t s1925 = table1[s1924];
  const uint16_t s1926 = (uint16_t) (s1899 >> 16);
  const uint8_t  s1927 = (uint8_t) s1926;
  const uint32_t s1928 = table2[s1927];
  const uint32_t s1929 = s1925 ^ s1928;
  const uint8_t  s1930 = (uint8_t) (s1916 >> 8);
  const uint32_t s1931 = table3[s1930];
  const uint32_t s1932 = s1929 ^ s1931;
  const uint16_t s1933 = (uint16_t) s1864;
  const uint8_t  s1934 = (uint8_t) s1933;
  const uint32_t s1935 = table4[s1934];
  const uint32_t s1936 = s1932 ^ s1935;
  const uint32_t s1937 = s49 ^ s1936;
  const uint16_t s1938 = (uint16_t) (s1937 >> 16);
  const uint8_t  s1939 = (uint8_t) s1938;
  const uint32_t s1940 = table2[s1939];
  const uint32_t s1941 = s1923 ^ s1940;
  const uint8_t  s1942 = (uint8_t) (s1926 >> 8);
  const uint32_t s1943 = table1[s1942];
  const uint16_t s1944 = (uint16_t) (s1915 >> 16);
  const uint8_t  s1945 = (uint8_t) s1944;
  const uint32_t s1946 = table2[s1945];
  const uint32_t s1947 = s1943 ^ s1946;
  const uint8_t  s1948 = (uint8_t) (s1933 >> 8);
  const uint32_t s1949 = table3[s1948];
  const uint32_t s1950 = s1947 ^ s1949;
  const uint16_t s1951 = (uint16_t) s1881;
  const uint8_t  s1952 = (uint8_t) s1951;
  const uint32_t s1953 = table4[s1952];
  const uint32_t s1954 = s1950 ^ s1953;
  const uint32_t s1955 = s50 ^ s1954;
  const uint16_t s1956 = (uint16_t) s1955;
  const uint8_t  s1957 = (uint8_t) (s1956 >> 8);
  const uint32_t s1958 = table3[s1957];
  const uint32_t s1959 = s1941 ^ s1958;
  const uint8_t  s1960 = (uint8_t) (s1944 >> 8);
  const uint32_t s1961 = table1[s1960];
  const uint8_t  s1962 = (uint8_t) s1865;
  const uint32_t s1963 = table2[s1962];
  const uint32_t s1964 = s1961 ^ s1963;
  const uint8_t  s1965 = (uint8_t) (s1951 >> 8);
  const uint32_t s1966 = table3[s1965];
  const uint32_t s1967 = s1964 ^ s1966;
  const uint8_t  s1968 = (uint8_t) s1900;
  const uint32_t s1969 = table4[s1968];
  const uint32_t s1970 = s1967 ^ s1969;
  const uint32_t s1971 = s51 ^ s1970;
  const uint16_t s1972 = (uint16_t) s1971;
  const uint8_t  s1973 = (uint8_t) s1972;
  const uint32_t s1974 = table4[s1973];
  const uint32_t s1975 = s1959 ^ s1974;
  const uint32_t s1976 = s52 ^ s1975;
  const uint16_t s1977 = (uint16_t) (s1976 >> 16);
  const uint8_t  s1978 = (uint8_t) (s1977 >> 8);
  const uint32_t s1979 = table1[s1978];
  const uint8_t  s1980 = (uint8_t) (s1938 >> 8);
  const uint32_t s1981 = table1[s1980];
  const uint16_t s1982 = (uint16_t) (s1955 >> 16);
  const uint8_t  s1983 = (uint8_t) s1982;
  const uint32_t s1984 = table2[s1983];
  const uint32_t s1985 = s1981 ^ s1984;
  const uint8_t  s1986 = (uint8_t) (s1972 >> 8);
  const uint32_t s1987 = table3[s1986];
  const uint32_t s1988 = s1985 ^ s1987;
  const uint16_t s1989 = (uint16_t) s1920;
  const uint8_t  s1990 = (uint8_t) s1989;
  const uint32_t s1991 = table4[s1990];
  const uint32_t s1992 = s1988 ^ s1991;
  const uint32_t s1993 = s53 ^ s1992;
  const uint16_t s1994 = (uint16_t) (s1993 >> 16);
  const uint8_t  s1995 = (uint8_t) s1994;
  const uint32_t s1996 = table2[s1995];
  const uint32_t s1997 = s1979 ^ s1996;
  const uint8_t  s1998 = (uint8_t) (s1982 >> 8);
  const uint32_t s1999 = table1[s1998];
  const uint16_t s2000 = (uint16_t) (s1971 >> 16);
  const uint8_t  s2001 = (uint8_t) s2000;
  const uint32_t s2002 = table2[s2001];
  const uint32_t s2003 = s1999 ^ s2002;
  const uint8_t  s2004 = (uint8_t) (s1989 >> 8);
  const uint32_t s2005 = table3[s2004];
  const uint32_t s2006 = s2003 ^ s2005;
  const uint16_t s2007 = (uint16_t) s1937;
  const uint8_t  s2008 = (uint8_t) s2007;
  const uint32_t s2009 = table4[s2008];
  const uint32_t s2010 = s2006 ^ s2009;
  const uint32_t s2011 = s54 ^ s2010;
  const uint16_t s2012 = (uint16_t) s2011;
  const uint8_t  s2013 = (uint8_t) (s2012 >> 8);
  const uint32_t s2014 = table3[s2013];
  const uint32_t s2015 = s1997 ^ s2014;
  const uint8_t  s2016 = (uint8_t) (s2000 >> 8);
  const uint32_t s2017 = table1[s2016];
  const uint8_t  s2018 = (uint8_t) s1921;
  const uint32_t s2019 = table2[s2018];
  const uint32_t s2020 = s2017 ^ s2019;
  const uint8_t  s2021 = (uint8_t) (s2007 >> 8);
  const uint32_t s2022 = table3[s2021];
  const uint32_t s2023 = s2020 ^ s2022;
  const uint8_t  s2024 = (uint8_t) s1956;
  const uint32_t s2025 = table4[s2024];
  const uint32_t s2026 = s2023 ^ s2025;
  const uint32_t s2027 = s55 ^ s2026;
  const uint16_t s2028 = (uint16_t) s2027;
  const uint8_t  s2029 = (uint8_t) s2028;
  const uint32_t s2030 = table4[s2029];
  const uint32_t s2031 = s2015 ^ s2030;
  const uint32_t s2032 = s56 ^ s2031;
  const uint16_t s2033 = (uint16_t) (s2032 >> 16);
  const uint8_t  s2034 = (uint8_t) (s2033 >> 8);
  const uint8_t  s2035 = table0[s2034];
  const uint8_t  s2036 = (uint8_t) (s1994 >> 8);
  const uint32_t s2037 = table1[s2036];
  const uint16_t s2038 = (uint16_t) (s2011 >> 16);
  const uint8_t  s2039 = (uint8_t) s2038;
  const uint32_t s2040 = table2[s2039];
  const uint32_t s2041 = s2037 ^ s2040;
  const uint8_t  s2042 = (uint8_t) (s2028 >> 8);
  const uint32_t s2043 = table3[s2042];
  const uint32_t s2044 = s2041 ^ s2043;
  const uint16_t s2045 = (uint16_t) s1976;
  const uint8_t  s2046 = (uint8_t) s2045;
  const uint32_t s2047 = table4[s2046];
  const uint32_t s2048 = s2044 ^ s2047;
  const uint32_t s2049 = s57 ^ s2048;
  const uint16_t s2050 = (uint16_t) (s2049 >> 16);
  const uint8_t  s2051 = (uint8_t) s2050;
  const uint8_t  s2052 = table0[s2051];
  const uint16_t s2053 = (((uint16_t) s2035) << 8) | ((uint16_t) s2052);
  const uint8_t  s2054 = (uint8_t) (s2038 >> 8);
  const uint32_t s2055 = table1[s2054];
  const uint16_t s2056 = (uint16_t) (s2027 >> 16);
  const uint8_t  s2057 = (uint8_t) s2056;
  const uint32_t s2058 = table2[s2057];
  const uint32_t s2059 = s2055 ^ s2058;
  const uint8_t  s2060 = (uint8_t) (s2045 >> 8);
  const uint32_t s2061 = table3[s2060];
  const uint32_t s2062 = s2059 ^ s2061;
  const uint16_t s2063 = (uint16_t) s1993;
  const uint8_t  s2064 = (uint8_t) s2063;
  const uint32_t s2065 = table4[s2064];
  const uint32_t s2066 = s2062 ^ s2065;
  const uint32_t s2067 = s58 ^ s2066;
  const uint16_t s2068 = (uint16_t) s2067;
  const uint8_t  s2069 = (uint8_t) (s2068 >> 8);
  const uint8_t  s2070 = table0[s2069];
  const uint8_t  s2071 = (uint8_t) (s2056 >> 8);
  const uint32_t s2072 = table1[s2071];
  const uint8_t  s2073 = (uint8_t) s1977;
  const uint32_t s2074 = table2[s2073];
  const uint32_t s2075 = s2072 ^ s2074;
  const uint8_t  s2076 = (uint8_t) (s2063 >> 8);
  const uint32_t s2077 = table3[s2076];
  const uint32_t s2078 = s2075 ^ s2077;
  const uint8_t  s2079 = (uint8_t) s2012;
  const uint32_t s2080 = table4[s2079];
  const uint32_t s2081 = s2078 ^ s2080;
  const uint32_t s2082 = s59 ^ s2081;
  const uint16_t s2083 = (uint16_t) s2082;
  const uint8_t  s2084 = (uint8_t) s2083;
  const uint8_t  s2085 = table0[s2084];
  const uint16_t s2086 = (((uint16_t) s2070) << 8) | ((uint16_t) s2085);
  const uint32_t s2087 = (((uint32_t) s2053) << 16) | ((uint32_t) s2086);
  const uint32_t s2088 = s60 ^ s2087;
  const uint8_t  s2089 = (uint8_t) (s2050 >> 8);
  const uint8_t  s2090 = table0[s2089];
  const uint16_t s2091 = (uint16_t) (s2067 >> 16);
  const uint8_t  s2092 = (uint8_t) s2091;
  const uint8_t  s2093 = table0[s2092];
  const uint16_t s2094 = (((uint16_t) s2090) << 8) | ((uint16_t) s2093);
  const uint8_t  s2095 = (uint8_t) (s2083 >> 8);
  const uint8_t  s2096 = table0[s2095];
  const uint16_t s2097 = (uint16_t) s2032;
  const uint8_t  s2098 = (uint8_t) s2097;
  const uint8_t  s2099 = table0[s2098];
  const uint16_t s2100 = (((uint16_t) s2096) << 8) | ((uint16_t) s2099);
  const uint32_t s2101 = (((uint32_t) s2094) << 16) | ((uint32_t) s2100);
  const uint32_t s2102 = s61 ^ s2101;
  const uint8_t  s2103 = (uint8_t) (s2091 >> 8);
  const uint8_t  s2104 = table0[s2103];
  const uint16_t s2105 = (uint16_t) (s2082 >> 16);
  const uint8_t  s2106 = (uint8_t) s2105;
  const uint8_t  s2107 = table0[s2106];
  const uint16_t s2108 = (((uint16_t) s2104) << 8) | ((uint16_t) s2107);
  const uint8_t  s2109 = (uint8_t) (s2097 >> 8);
  const uint8_t  s2110 = table0[s2109];
  const uint16_t s2111 = (uint16_t) s2049;
  const uint8_t  s2112 = (uint8_t) s2111;
  const uint8_t  s2113 = table0[s2112];
  const uint16_t s2114 = (((uint16_t) s2110) << 8) | ((uint16_t) s2113);
  const uint32_t s2115 = (((uint32_t) s2108) << 16) | ((uint32_t) s2114);
  const uint32_t s2116 = s62 ^ s2115;
  const uint8_t  s2117 = (uint8_t) (s2105 >> 8);
  const uint8_t  s2118 = table0[s2117];
  const uint8_t  s2119 = (uint8_t) s2033;
  const uint8_t  s2120 = table0[s2119];
  const uint16_t s2121 = (((uint16_t) s2118) << 8) | ((uint16_t) s2120);
  const uint8_t  s2122 = (uint8_t) (s2111 >> 8);
  const uint8_t  s2123 = table0[s2122];
  const uint8_t  s2124 = (uint8_t) s2068;
  const uint8_t  s2125 = table0[s2124];
  const uint16_t s2126 = (((uint16_t) s2123) << 8) | ((uint16_t) s2125);
  const uint32_t s2127 = (((uint32_t) s2121) << 16) | ((uint32_t) s2126);
  const uint32_t s2128 = s63 ^ s2127;

  ct[0] = s2088;
  ct[1] = s2102;
  ct[2] = s2116;
  ct[3] = s2128;
}
