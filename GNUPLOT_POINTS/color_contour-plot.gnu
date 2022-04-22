 set encoding iso_8859_1; 
 set terminal postscript eps enhanced color colortext font "Arial,18" size 5,5 linewidth 1
 set output 'f.eps'
 reset
 xmn =  -0.9
 xmx =  20.0
 ymn =  -0.9
 ymx =  10.0
 set xrange [xmn:xmx]
 set yrange [ymn:ymx]
 unset key
 unset colorbox
 set xtics 1
 set ytics 1
 set cbtics ("" 0)
 set cbrange[0:20]
 set palette rgbformulae 33,13,10
 set pm3d map interpolate 1,1
 set pointsize 1.5
sp  'p-0' u 1:2:3 w p 0, 'p-1' u 1:2:3 w p 1, 'p-2' u 1:2:3 w p 2, 'p-3' u 1:2:3 w p 3, 'p-4' u 1:2:3 w p 4, 'p-5' u 1:2:3 w p 5, 'p-6' u 1:2:3 w p 6, 'p-7' u 1:2:3 w p 7, 'p-8' u 1:2:3 w p 8, 'p-9' u 1:2:3 w p 9, 'p-10' u 1:2:3 w p 10, 'p-11' u 1:2:3 w p 11, 'p-12' u 1:2:3 w p 12, 'p-13' u 1:2:3 w p 13, 'p-14' u 1:2:3 w p 14, 'p-15' u 1:2:3 w p 15, 'p-16' u 1:2:3 w p 16, 'p-17' u 1:2:3 w p 17, 'p-18' u 1:2:3 w p 18, 'p-19' u 1:2:3 w p 19, 'p-20' u 1:2:3 w p 20, 'p-21' u 1:2:3 w p 21, 'p-22' u 1:2:3 w p 22, 'p-23' u 1:2:3 w p 23, 'p-24' u 1:2:3 w p 24, 'p-25' u 1:2:3 w p 25, 'p-26' u 1:2:3 w p 26, 'p-27' u 1:2:3 w p 27, 'p-28' u 1:2:3 w p 28, 'p-29' u 1:2:3 w p 29, 'p-30' u 1:2:3 w p 30, 'p-31' u 1:2:3 w p 31, 'p-32' u 1:2:3 w p 32, 'p-33' u 1:2:3 w p 33, 'p-34' u 1:2:3 w p 34, 'p-35' u 1:2:3 w p 35, 'p-36' u 1:2:3 w p 36, 'p-37' u 1:2:3 w p 37, 'p-38' u 1:2:3 w p 38, 'p-39' u 1:2:3 w p 39, 'p-40' u 1:2:3 w p 40, 'p-41' u 1:2:3 w p 41, 'p-42' u 1:2:3 w p 42, 'p-43' u 1:2:3 w p 43, 'p-44' u 1:2:3 w p 44, 'p-45' u 1:2:3 w p 45, 'p-46' u 1:2:3 w p 46, 'p-47' u 1:2:3 w p 47, 'p-48' u 1:2:3 w p 48, 'p-49' u 1:2:3 w p 49, 'p-50' u 1:2:3 w p 50, 'p-51' u 1:2:3 w p 51, 'p-52' u 1:2:3 w p 52, 'p-53' u 1:2:3 w p 53, 'p-54' u 1:2:3 w p 54, 'p-55' u 1:2:3 w p 55, 'p-56' u 1:2:3 w p 56, 'p-57' u 1:2:3 w p 57, 'p-58' u 1:2:3 w p 58, 'p-59' u 1:2:3 w p 59, 'p-60' u 1:2:3 w p 60, 'p-61' u 1:2:3 w p 61, 'p-62' u 1:2:3 w p 62, 'p-63' u 1:2:3 w p 63, 'p-64' u 1:2:3 w p 64, 'p-65' u 1:2:3 w p 65, 'p-66' u 1:2:3 w p 66, 'p-67' u 1:2:3 w p 67, 'p-68' u 1:2:3 w p 68, 'p-69' u 1:2:3 w p 69, 'p-70' u 1:2:3 w p 70, 'p-71' u 1:2:3 w p 71, 'p-72' u 1:2:3 w p 72, 'p-73' u 1:2:3 w p 73, 'p-74' u 1:2:3 w p 74, 'p-75' u 1:2:3 w p 75, 'p-76' u 1:2:3 w p 76, 'p-77' u 1:2:3 w p 77, 'p-78' u 1:2:3 w p 78, 'p-79' u 1:2:3 w p 79, 'p-80' u 1:2:3 w p 80, 'p-81' u 1:2:3 w p 81, 'p-82' u 1:2:3 w p 82, 'p-83' u 1:2:3 w p 83, 'p-84' u 1:2:3 w p 84, 'p-85' u 1:2:3 w p 85, 'p-86' u 1:2:3 w p 86, 'p-87' u 1:2:3 w p 87, 'p-88' u 1:2:3 w p 88, 'p-89' u 1:2:3 w p 89, 'p-90' u 1:2:3 w p 90, 'p-91' u 1:2:3 w p 91, 'p-92' u 1:2:3 w p 92, 'p-93' u 1:2:3 w p 93, 'p-94' u 1:2:3 w p 94, 'p-95' u 1:2:3 w p 95, 'p-96' u 1:2:3 w p 96, 'p-97' u 1:2:3 w p 97, 'p-98' u 1:2:3 w p 98, 'p-99' u 1:2:3 w p 99, 'p-100' u 1:2:3 w p 100, 'p-101' u 1:2:3 w p 101, 'p-102' u 1:2:3 w p 102, 'p-103' u 1:2:3 w p 103, 'p-104' u 1:2:3 w p 104, 'p-105' u 1:2:3 w p 105, 'p-106' u 1:2:3 w p 106, 'p-107' u 1:2:3 w p 107, 'p-108' u 1:2:3 w p 108, 'p-109' u 1:2:3 w p 109, 'p-110' u 1:2:3 w p 110, 'p-111' u 1:2:3 w p 111, 'p-112' u 1:2:3 w p 112, 'p-113' u 1:2:3 w p 113, 'p-114' u 1:2:3 w p 114, 'p-115' u 1:2:3 w p 115, 'p-116' u 1:2:3 w p 116, 'p-117' u 1:2:3 w p 117, 'p-118' u 1:2:3 w p 118, 'p-119' u 1:2:3 w p 119, 'p-120' u 1:2:3 w p 120, 'p-121' u 1:2:3 w p 121, 'p-122' u 1:2:3 w p 122, 'p-123' u 1:2:3 w p 123, 'p-124' u 1:2:3 w p 124, 'p-125' u 1:2:3 w p 125, 'p-126' u 1:2:3 w p 126, 'p-127' u 1:2:3 w p 127, 'p-128' u 1:2:3 w p 128, 'p-129' u 1:2:3 w p 129, 'p-130' u 1:2:3 w p 130, 'p-131' u 1:2:3 w p 131, 'p-132' u 1:2:3 w p 132, 'p-133' u 1:2:3 w p 133, 'p-134' u 1:2:3 w p 134, 'p-135' u 1:2:3 w p 135, 'p-136' u 1:2:3 w p 136, 'p-137' u 1:2:3 w p 137, 'p-138' u 1:2:3 w p 138, 'p-139' u 1:2:3 w p 139, 'p-140' u 1:2:3 w p 140, 'p-141' u 1:2:3 w p 141, 'p-142' u 1:2:3 w p 142, 'p-143' u 1:2:3 w p 143, 'p-144' u 1:2:3 w p 144, 'p-145' u 1:2:3 w p 145, 'p-146' u 1:2:3 w p 146, 'p-147' u 1:2:3 w p 147, 'p-148' u 1:2:3 w p 148, 'p-149' u 1:2:3 w p 149, 'p-150' u 1:2:3 w p 150, 'p-151' u 1:2:3 w p 151, 'p-152' u 1:2:3 w p 152, 'p-153' u 1:2:3 w p 153, 'p-154' u 1:2:3 w p 154, 'p-155' u 1:2:3 w p 155, 'p-156' u 1:2:3 w p 156, 'p-157' u 1:2:3 w p 157, 'p-158' u 1:2:3 w p 158, 'p-159' u 1:2:3 w p 159, 'p-160' u 1:2:3 w p 160, 'p-161' u 1:2:3 w p 161, 'p-162' u 1:2:3 w p 162, 'p-163' u 1:2:3 w p 163, 'p-164' u 1:2:3 w p 164, 'p-165' u 1:2:3 w p 165, 'p-166' u 1:2:3 w p 166, 'p-167' u 1:2:3 w p 167, 'p-168' u 1:2:3 w p 168, 'p-169' u 1:2:3 w p 169, 'p-170' u 1:2:3 w p 170, 'p-171' u 1:2:3 w p 171, 'p-172' u 1:2:3 w p 172, 'p-173' u 1:2:3 w p 173, 'p-174' u 1:2:3 w p 174, 'p-175' u 1:2:3 w p 175, 'p-176' u 1:2:3 w p 176, 'p-177' u 1:2:3 w p 177, 'p-178' u 1:2:3 w p 178, 'p-179' u 1:2:3 w p 179, 'p-180' u 1:2:3 w p 180, 'p-181' u 1:2:3 w p 181, 'p-182' u 1:2:3 w p 182, 'p-183' u 1:2:3 w p 183, 'p-184' u 1:2:3 w p 184, 'p-185' u 1:2:3 w p 185, 'p-186' u 1:2:3 w p 186, 'p-187' u 1:2:3 w p 187, 'p-188' u 1:2:3 w p 188, 'p-189' u 1:2:3 w p 189, 'p-190' u 1:2:3 w p 190, 'p-191' u 1:2:3 w p 191, 'p-192' u 1:2:3 w p 192, 'p-193' u 1:2:3 w p 193, 'p-194' u 1:2:3 w p 194, 'p-195' u 1:2:3 w p 195, 'p-196' u 1:2:3 w p 196, 'p-197' u 1:2:3 w p 197, 'p-198' u 1:2:3 w p 198, 'p-199' u 1:2:3 w p 199, 'p-200' u 1:2:3 w p 200, 'p-201' u 1:2:3 w p 201, 'p-202' u 1:2:3 w p 202, 'p-203' u 1:2:3 w p 203, 'p-204' u 1:2:3 w p 204, 'p-205' u 1:2:3 w p 205, 'p-206' u 1:2:3 w p 206, 'p-207' u 1:2:3 w p 207, 'p-208' u 1:2:3 w p 208, 'p-209' u 1:2:3 w p 209, 'p-210' u 1:2:3 w p 210, 'p-211' u 1:2:3 w p 211, 'p-212' u 1:2:3 w p 212, 'p-213' u 1:2:3 w p 213, 'p-214' u 1:2:3 w p 214, 'p-215' u 1:2:3 w p 215, 'p-216' u 1:2:3 w p 216, 'p-217' u 1:2:3 w p 217, 'p-218' u 1:2:3 w p 218, 'p-219' u 1:2:3 w p 219, 'p-220' u 1:2:3 w p 220, 'p-221' u 1:2:3 w p 221, 'p-222' u 1:2:3 w p 222, 'p-223' u 1:2:3 w p 223, 'p-224' u 1:2:3 w p 224, 'p-225' u 1:2:3 w p 225, 'p-226' u 1:2:3 w p 226, 'p-227' u 1:2:3 w p 227, 'p-228' u 1:2:3 w p 228, 'p-229' u 1:2:3 w p 229, 'p-230' u 1:2:3 w p 230, 'p-231' u 1:2:3 w p 231, 'p-232' u 1:2:3 w p 232, 'p-233' u 1:2:3 w p 233, 'p-234' u 1:2:3 w p 234, 'p-235' u 1:2:3 w p 235, 'p-236' u 1:2:3 w p 236, 'p-237' u 1:2:3 w p 237, 'p-238' u 1:2:3 w p 238, 'p-239' u 1:2:3 w p 239, 'p-240' u 1:2:3 w p 240, 'p-241' u 1:2:3 w p 241, 'p-242' u 1:2:3 w p 242, 'p-243' u 1:2:3 w p 243, 'p-244' u 1:2:3 w p 244, 'p-245' u 1:2:3 w p 245, 'p-246' u 1:2:3 w p 246, 'p-247' u 1:2:3 w p 247, 'p-248' u 1:2:3 w p 248, 'p-249' u 1:2:3 w p 249, 'p-250' u 1:2:3 w p 250, 'p-251' u 1:2:3 w p 251, 'p-252' u 1:2:3 w p 252, 'p-253' u 1:2:3 w p 253, 'p-254' u 1:2:3 w p 254, 'p-255' u 1:2:3 w p 255, 'p-256' u 1:2:3 w p 256, 'p-257' u 1:2:3 w p 257, 'p-258' u 1:2:3 w p 258, 'p-259' u 1:2:3 w p 259, 'p-260' u 1:2:3 w p 260, 'p-261' u 1:2:3 w p 261, 'p-262' u 1:2:3 w p 262, 'p-263' u 1:2:3 w p 263, 'p-264' u 1:2:3 w p 264, 'p-265' u 1:2:3 w p 265, 'p-266' u 1:2:3 w p 266, 'p-267' u 1:2:3 w p 267, 'p-268' u 1:2:3 w p 268, 'p-269' u 1:2:3 w p 269, 'p-270' u 1:2:3 w p 270, 'p-271' u 1:2:3 w p 271, 'p-272' u 1:2:3 w p 272, 'p-273' u 1:2:3 w p 273, 'p-274' u 1:2:3 w p 274, 'p-275' u 1:2:3 w p 275, 'p-276' u 1:2:3 w p 276, 'p-277' u 1:2:3 w p 277, 'p-278' u 1:2:3 w p 278, 'p-279' u 1:2:3 w p 279, 'p-280' u 1:2:3 w p 280, 'p-281' u 1:2:3 w p 281, 'p-282' u 1:2:3 w p 282, 'p-283' u 1:2:3 w p 283, 'p-284' u 1:2:3 w p 284, 'p-285' u 1:2:3 w p 285, 'p-286' u 1:2:3 w p 286, 'p-287' u 1:2:3 w p 287, 'p-288' u 1:2:3 w p 288, 'p-289' u 1:2:3 w p 289, 'p-290' u 1:2:3 w p 290, 'p-291' u 1:2:3 w p 291, 'p-292' u 1:2:3 w p 292, 'p-293' u 1:2:3 w p 293, 'p-294' u 1:2:3 w p 294, 'p-295' u 1:2:3 w p 295, 'p-296' u 1:2:3 w p 296, 'p-297' u 1:2:3 w p 297, 'p-298' u 1:2:3 w p 298, 'p-299' u 1:2:3 w p 299, 'p-300' u 1:2:3 w p 300, 'p-301' u 1:2:3 w p 301, 'p-302' u 1:2:3 w p 302, 'p-303' u 1:2:3 w p 303, 'p-304' u 1:2:3 w p 304, 'p-305' u 1:2:3 w p 305, 'p-306' u 1:2:3 w p 306, 'p-307' u 1:2:3 w p 307, 'p-308' u 1:2:3 w p 308, 'p-309' u 1:2:3 w p 309, 'p-310' u 1:2:3 w p 310, 'p-311' u 1:2:3 w p 311, 'p-312' u 1:2:3 w p 312, 'p-313' u 1:2:3 w p 313, 'p-314' u 1:2:3 w p 314, 'p-315' u 1:2:3 w p 315, 'p-316' u 1:2:3 w p 316, 'p-317' u 1:2:3 w p 317, 'p-318' u 1:2:3 w p 318, 'p-319' u 1:2:3 w p 319, 'p-320' u 1:2:3 w p 320, 'p-321' u 1:2:3 w p 321, 'p-322' u 1:2:3 w p 322, 'p-323' u 1:2:3 w p 323, 'p-324' u 1:2:3 w p 324, 'p-325' u 1:2:3 w p 325, 'p-326' u 1:2:3 w p 326, 'p-327' u 1:2:3 w p 327, 'p-328' u 1:2:3 w p 328, 'p-329' u 1:2:3 w p 329, 'p-330' u 1:2:3 w p 330, 'p-331' u 1:2:3 w p 331, 'p-332' u 1:2:3 w p 332, 'p-333' u 1:2:3 w p 333, 'p-334' u 1:2:3 w p 334, 'p-335' u 1:2:3 w p 335, 'p-336' u 1:2:3 w p 336, 'p-337' u 1:2:3 w p 337, 'p-338' u 1:2:3 w p 338, 'p-339' u 1:2:3 w p 339, 'p-340' u 1:2:3 w p 340, 'p-341' u 1:2:3 w p 341, 'p-342' u 1:2:3 w p 342, 'p-343' u 1:2:3 w p 343, 'p-344' u 1:2:3 w p 344, 'p-345' u 1:2:3 w p 345, 'p-346' u 1:2:3 w p 346, 'p-347' u 1:2:3 w p 347, 'p-348' u 1:2:3 w p 348, 'p-349' u 1:2:3 w p 349, 'p-350' u 1:2:3 w p 350, 'p-351' u 1:2:3 w p 351, 'p-352' u 1:2:3 w p 352, 'p-353' u 1:2:3 w p 353, 'p-354' u 1:2:3 w p 354, 'p-355' u 1:2:3 w p 355, 'p-356' u 1:2:3 w p 356, 'p-357' u 1:2:3 w p 357, 'p-358' u 1:2:3 w p 358, 'p-359' u 1:2:3 w p 359, 'p-360' u 1:2:3 w p 360, 'p-361' u 1:2:3 w p 361, 'p-362' u 1:2:3 w p 362, 'p-363' u 1:2:3 w p 363, 'p-364' u 1:2:3 w p 364, 'p-365' u 1:2:3 w p 365, 'p-366' u 1:2:3 w p 366, 'p-367' u 1:2:3 w p 367, 'p-368' u 1:2:3 w p 368, 'p-369' u 1:2:3 w p 369, 'p-370' u 1:2:3 w p 370, 'p-371' u 1:2:3 w p 371, 'p-372' u 1:2:3 w p 372, 'p-373' u 1:2:3 w p 373, 'p-374' u 1:2:3 w p 374, 'p-375' u 1:2:3 w p 375, 'p-376' u 1:2:3 w p 376, 'p-377' u 1:2:3 w p 377, 'p-378' u 1:2:3 w p 378, 'p-379' u 1:2:3 w p 379, 'p-380' u 1:2:3 w p 380, 'p-381' u 1:2:3 w p 381, 'p-382' u 1:2:3 w p 382, 'p-383' u 1:2:3 w p 383, 'p-384' u 1:2:3 w p 384, 'p-385' u 1:2:3 w p 385, 'p-386' u 1:2:3 w p 386, 'p-387' u 1:2:3 w p 387, 'p-388' u 1:2:3 w p 388, 'p-389' u 1:2:3 w p 389, 'p-390' u 1:2:3 w p 390, 'p-391' u 1:2:3 w p 391, 'p-392' u 1:2:3 w p 392, 'p-393' u 1:2:3 w p 393, 'p-394' u 1:2:3 w p 394, 'p-395' u 1:2:3 w p 395, 'p-396' u 1:2:3 w p 396, 'p-397' u 1:2:3 w p 397, 'p-398' u 1:2:3 w p 398, 'p-399' u 1:2:3 w p 399, 'p-400' u 1:2:3 w p 400, 'p-401' u 1:2:3 w p 401, 'p-402' u 1:2:3 w p 402, 'p-403' u 1:2:3 w p 403, 'p-404' u 1:2:3 w p 404, 'p-405' u 1:2:3 w p 405, 'p-406' u 1:2:3 w p 406, 'p-407' u 1:2:3 w p 407, 'p-408' u 1:2:3 w p 408, 'p-409' u 1:2:3 w p 409, 'p-410' u 1:2:3 w p 410, 'p-411' u 1:2:3 w p 411, 'p-412' u 1:2:3 w p 412, 'p-413' u 1:2:3 w p 413, 'p-414' u 1:2:3 w p 414, 'p-415' u 1:2:3 w p 415, 'p-416' u 1:2:3 w p 416, 'p-417' u 1:2:3 w p 417, 'p-418' u 1:2:3 w p 418, 'p-419' u 1:2:3 w p 419, 'p-420' u 1:2:3 w p 420, 'p-421' u 1:2:3 w p 421, 'p-422' u 1:2:3 w p 422, 'p-423' u 1:2:3 w p 423, 'p-424' u 1:2:3 w p 424, 'p-425' u 1:2:3 w p 425, 'p-426' u 1:2:3 w p 426, 'p-427' u 1:2:3 w p 427, 'p-428' u 1:2:3 w p 428, 'p-429' u 1:2:3 w p 429, 'p-430' u 1:2:3 w p 430, 'p-431' u 1:2:3 w p 431, 'p-432' u 1:2:3 w p 432, 'p-433' u 1:2:3 w p 433, 'p-434' u 1:2:3 w p 434, 'p-435' u 1:2:3 w p 435, 'p-436' u 1:2:3 w p 436, 'p-437' u 1:2:3 w p 437, 'p-438' u 1:2:3 w p 438, 'p-439' u 1:2:3 w p 439, 'p-440' u 1:2:3 w p 440, 'p-441' u 1:2:3 w p 441, 'p-442' u 1:2:3 w p 442, 'p-443' u 1:2:3 w p 443, 'p-444' u 1:2:3 w p 444, 'p-445' u 1:2:3 w p 445, 'p-446' u 1:2:3 w p 446, 'p-447' u 1:2:3 w p 447, 'p-448' u 1:2:3 w p 448, 'p-449' u 1:2:3 w p 449, 'p-450' u 1:2:3 w p 450, 'p-451' u 1:2:3 w p 451, 'p-452' u 1:2:3 w p 452, 'p-453' u 1:2:3 w p 453, 'p-454' u 1:2:3 w p 454, 'p-455' u 1:2:3 w p 455, 'p-456' u 1:2:3 w p 456, 'p-457' u 1:2:3 w p 457, 'p-458' u 1:2:3 w p 458, 'p-459' u 1:2:3 w p 459, 'p-460' u 1:2:3 w p 460, 'p-461' u 1:2:3 w p 461, 'p-462' u 1:2:3 w p 462, 'p-463' u 1:2:3 w p 463, 'p-464' u 1:2:3 w p 464, 'p-465' u 1:2:3 w p 465, 'p-466' u 1:2:3 w p 466, 'p-467' u 1:2:3 w p 467, 'p-468' u 1:2:3 w p 468, 'p-469' u 1:2:3 w p 469, 'p-470' u 1:2:3 w p 470, 'p-471' u 1:2:3 w p 471, 'p-472' u 1:2:3 w p 472, 'p-473' u 1:2:3 w p 473, 'p-474' u 1:2:3 w p 474, 'p-475' u 1:2:3 w p 475, 'p-476' u 1:2:3 w p 476, 'p-477' u 1:2:3 w p 477, 'p-478' u 1:2:3 w p 478, 'p-479' u 1:2:3 w p 479, 'p-480' u 1:2:3 w p 480, 'p-481' u 1:2:3 w p 481, 'p-482' u 1:2:3 w p 482, 'p-483' u 1:2:3 w p 483, 'p-484' u 1:2:3 w p 484, 'p-485' u 1:2:3 w p 485, 'p-486' u 1:2:3 w p 486, 'p-487' u 1:2:3 w p 487, 'p-488' u 1:2:3 w p 488, 'p-489' u 1:2:3 w p 489, 'p-490' u 1:2:3 w p 490, 'p-491' u 1:2:3 w p 491, 'p-492' u 1:2:3 w p 492, 'p-493' u 1:2:3 w p 493, 'p-494' u 1:2:3 w p 494, 'p-495' u 1:2:3 w p 495, 'p-496' u 1:2:3 w p 496, 'p-497' u 1:2:3 w p 497, 'p-498' u 1:2:3 w p 498, 'p-499' u 1:2:3 w p 499, 'p-500' u 1:2:3 w p 500, 'p-501' u 1:2:3 w p 501, 'p-502' u 1:2:3 w p 502, 'p-503' u 1:2:3 w p 503, 'p-504' u 1:2:3 w p 504, 'p-505' u 1:2:3 w p 505, 'p-506' u 1:2:3 w p 506, 'p-507' u 1:2:3 w p 507, 'p-508' u 1:2:3 w p 508, 'p-509' u 1:2:3 w p 509, 'p-510' u 1:2:3 w p 510, 'p-511' u 1:2:3 w p 511, 'p-512' u 1:2:3 w p 512, 'p-513' u 1:2:3 w p 513, 'p-514' u 1:2:3 w p 514, 'p-515' u 1:2:3 w p 515, 'p-516' u 1:2:3 w p 516, 'p-517' u 1:2:3 w p 517, 'p-518' u 1:2:3 w p 518, 'p-519' u 1:2:3 w p 519, 'p-520' u 1:2:3 w p 520, 'p-521' u 1:2:3 w p 521, 'p-522' u 1:2:3 w p 522, 'p-523' u 1:2:3 w p 523, 'p-524' u 1:2:3 w p 524, 'p-525' u 1:2:3 w p 525, 'p-526' u 1:2:3 w p 526, 'p-527' u 1:2:3 w p 527, 'p-528' u 1:2:3 w p 528, 'p-529' u 1:2:3 w p 529, 'p-530' u 1:2:3 w p 530, 'p-531' u 1:2:3 w p 531, 'p-532' u 1:2:3 w p 532, 'p-533' u 1:2:3 w p 533, 'p-534' u 1:2:3 w p 534, 'p-535' u 1:2:3 w p 535, 'p-536' u 1:2:3 w p 536, 'p-537' u 1:2:3 w p 537, 'p-538' u 1:2:3 w p 538, 'p-539' u 1:2:3 w p 539, 'p-540' u 1:2:3 w p 540, 'p-541' u 1:2:3 w p 541, 'p-542' u 1:2:3 w p 542, 'p-543' u 1:2:3 w p 543, 'p-544' u 1:2:3 w p 544, 'p-545' u 1:2:3 w p 545, 'p-546' u 1:2:3 w p 546, 'p-547' u 1:2:3 w p 547, 'p-548' u 1:2:3 w p 548, 'p-549' u 1:2:3 w p 549, 'p-550' u 1:2:3 w p 550, 'p-551' u 1:2:3 w p 551, 'p-552' u 1:2:3 w p 552, 'p-553' u 1:2:3 w p 553, 'p-554' u 1:2:3 w p 554, 'p-555' u 1:2:3 w p 555, 'p-556' u 1:2:3 w p 556, 'p-557' u 1:2:3 w p 557, 'p-558' u 1:2:3 w p 558, 'p-559' u 1:2:3 w p 559, 'p-560' u 1:2:3 w p 560, 'p-561' u 1:2:3 w p 561, 'p-562' u 1:2:3 w p 562, 'p-563' u 1:2:3 w p 563, 'p-564' u 1:2:3 w p 564, 'p-565' u 1:2:3 w p 565, 'p-566' u 1:2:3 w p 566, 'p-567' u 1:2:3 w p 567, 'p-568' u 1:2:3 w p 568, 'p-569' u 1:2:3 w p 569, 'p-570' u 1:2:3 w p 570, 'p-571' u 1:2:3 w p 571, 'p-572' u 1:2:3 w p 572, 'p-573' u 1:2:3 w p 573, 'p-574' u 1:2:3 w p 574, 'p-575' u 1:2:3 w p 575, 'p-576' u 1:2:3 w p 576, 'p-577' u 1:2:3 w p 577, 'p-578' u 1:2:3 w p 578, 'p-579' u 1:2:3 w p 579, 'p-580' u 1:2:3 w p 580, 'p-581' u 1:2:3 w p 581, 'p-582' u 1:2:3 w p 582, 'p-583' u 1:2:3 w p 583, 'p-584' u 1:2:3 w p 584, 'p-585' u 1:2:3 w p 585, 'p-586' u 1:2:3 w p 586, 'p-587' u 1:2:3 w p 587, 'p-588' u 1:2:3 w p 588, 'p-589' u 1:2:3 w p 589, 'p-590' u 1:2:3 w p 590, 'p-591' u 1:2:3 w p 591, 'p-592' u 1:2:3 w p 592, 'p-593' u 1:2:3 w p 593, 'p-594' u 1:2:3 w p 594, 'p-595' u 1:2:3 w p 595, 'p-596' u 1:2:3 w p 596, 'p-597' u 1:2:3 w p 597, 'p-598' u 1:2:3 w p 598, 'p-599' u 1:2:3 w p 599, 'p-600' u 1:2:3 w p 600, 'p-601' u 1:2:3 w p 601, 'p-602' u 1:2:3 w p 602, 'p-603' u 1:2:3 w p 603, 'p-604' u 1:2:3 w p 604, 'p-605' u 1:2:3 w p 605, 'p-606' u 1:2:3 w p 606, 'p-607' u 1:2:3 w p 607, 'p-608' u 1:2:3 w p 608, 'p-609' u 1:2:3 w p 609, 'p-610' u 1:2:3 w p 610, 'p-611' u 1:2:3 w p 611, 'p-612' u 1:2:3 w p 612, 'p-613' u 1:2:3 w p 613, 'p-614' u 1:2:3 w p 614, 'p-615' u 1:2:3 w p 615, 'p-616' u 1:2:3 w p 616, 'p-617' u 1:2:3 w p 617, 'p-618' u 1:2:3 w p 618, 'p-619' u 1:2:3 w p 619, 'p-620' u 1:2:3 w p 620, 'p-621' u 1:2:3 w p 621, 'p-622' u 1:2:3 w p 622, 'p-623' u 1:2:3 w p 623, 'p-624' u 1:2:3 w p 624, 'p-625' u 1:2:3 w p 625, 'p-626' u 1:2:3 w p 626, 'p-627' u 1:2:3 w p 627, 'p-628' u 1:2:3 w p 628, 'p-629' u 1:2:3 w p 629, 'p-630' u 1:2:3 w p 630, 'p-631' u 1:2:3 w p 631, 'p-632' u 1:2:3 w p 632, 'p-633' u 1:2:3 w p 633, 'p-634' u 1:2:3 w p 634, 'p-635' u 1:2:3 w p 635, 'p-636' u 1:2:3 w p 636, 'p-637' u 1:2:3 w p 637, 'p-638' u 1:2:3 w p 638, 'p-639' u 1:2:3 w p 639, 'p-640' u 1:2:3 w p 640, 'p-641' u 1:2:3 w p 641, 'p-642' u 1:2:3 w p 642, 'p-643' u 1:2:3 w p 643, 'p-644' u 1:2:3 w p 644, 'p-645' u 1:2:3 w p 645, 'p-646' u 1:2:3 w p 646, 'p-647' u 1:2:3 w p 647, 'p-648' u 1:2:3 w p 648, 'p-649' u 1:2:3 w p 649, 'p-650' u 1:2:3 w p 650, 'p-651' u 1:2:3 w p 651, 'p-652' u 1:2:3 w p 652, 'p-653' u 1:2:3 w p 653, 'p-654' u 1:2:3 w p 654, 'p-655' u 1:2:3 w p 655, 'p-656' u 1:2:3 w p 656, 'p-657' u 1:2:3 w p 657, 'p-658' u 1:2:3 w p 658, 'p-659' u 1:2:3 w p 659, 'p-660' u 1:2:3 w p 660, 'p-661' u 1:2:3 w p 661, 'p-662' u 1:2:3 w p 662, 'p-663' u 1:2:3 w p 663, 'p-664' u 1:2:3 w p 664, 'p-665' u 1:2:3 w p 665, 'p-666' u 1:2:3 w p 666, 'p-667' u 1:2:3 w p 667, 'p-668' u 1:2:3 w p 668, 'p-669' u 1:2:3 w p 669, 'p-670' u 1:2:3 w p 670, 'p-671' u 1:2:3 w p 671, 'p-672' u 1:2:3 w p 672, 'p-673' u 1:2:3 w p 673, 'p-674' u 1:2:3 w p 674, 'p-675' u 1:2:3 w p 675, 'p-676' u 1:2:3 w p 676, 'p-677' u 1:2:3 w p 677, 'p-678' u 1:2:3 w p 678, 'p-679' u 1:2:3 w p 679, 'p-680' u 1:2:3 w p 680, 'p-681' u 1:2:3 w p 681, 'p-682' u 1:2:3 w p 682, 'p-683' u 1:2:3 w p 683, 'p-684' u 1:2:3 w p 684, 'p-685' u 1:2:3 w p 685, 'p-686' u 1:2:3 w p 686, 'p-687' u 1:2:3 w p 687, 'p-688' u 1:2:3 w p 688, 'p-689' u 1:2:3 w p 689, 'p-690' u 1:2:3 w p 690, 'p-691' u 1:2:3 w p 691, 'p-692' u 1:2:3 w p 692, 'p-693' u 1:2:3 w p 693, 'p-694' u 1:2:3 w p 694, 'p-695' u 1:2:3 w p 695, 'p-696' u 1:2:3 w p 696, 'p-697' u 1:2:3 w p 697, 'p-698' u 1:2:3 w p 698, 'p-699' u 1:2:3 w p 699, 'p-700' u 1:2:3 w p 700, 'p-701' u 1:2:3 w p 701, 'p-702' u 1:2:3 w p 702, 'p-703' u 1:2:3 w p 703, 'p-704' u 1:2:3 w p 704, 'p-705' u 1:2:3 w p 705, 'p-706' u 1:2:3 w p 706, 'p-707' u 1:2:3 w p 707, 'p-708' u 1:2:3 w p 708, 'p-709' u 1:2:3 w p 709, 'p-710' u 1:2:3 w p 710, 'p-711' u 1:2:3 w p 711, 'p-712' u 1:2:3 w p 712, 'p-713' u 1:2:3 w p 713, 'p-714' u 1:2:3 w p 714, 'p-715' u 1:2:3 w p 715, 'p-716' u 1:2:3 w p 716, 'p-717' u 1:2:3 w p 717, 'p-718' u 1:2:3 w p 718, 'p-719' u 1:2:3 w p 719, 'p-720' u 1:2:3 w p 720, 'p-721' u 1:2:3 w p 721, 'p-722' u 1:2:3 w p 722, 'p-723' u 1:2:3 w p 723, 'p-724' u 1:2:3 w p 724, 'p-725' u 1:2:3 w p 725, 'p-726' u 1:2:3 w p 726, 'p-727' u 1:2:3 w p 727, 'p-728' u 1:2:3 w p 728, 'p-729' u 1:2:3 w p 729, 'p-730' u 1:2:3 w p 730, 'p-731' u 1:2:3 w p 731, 'p-732' u 1:2:3 w p 732, 'p-733' u 1:2:3 w p 733, 'p-734' u 1:2:3 w p 734, 'p-735' u 1:2:3 w p 735, 'p-736' u 1:2:3 w p 736, 'p-737' u 1:2:3 w p 737, 'p-738' u 1:2:3 w p 738, 'p-739' u 1:2:3 w p 739, 'p-740' u 1:2:3 w p 740, 'p-741' u 1:2:3 w p 741, 'p-742' u 1:2:3 w p 742, 'p-743' u 1:2:3 w p 743, 'p-744' u 1:2:3 w p 744, 'p-745' u 1:2:3 w p 745, 'p-746' u 1:2:3 w p 746, 'p-747' u 1:2:3 w p 747, 'p-748' u 1:2:3 w p 748, 'p-749' u 1:2:3 w p 749, 'p-750' u 1:2:3 w p 750, 'p-751' u 1:2:3 w p 751, 'p-752' u 1:2:3 w p 752, 'p-753' u 1:2:3 w p 753, 'p-754' u 1:2:3 w p 754, 'p-755' u 1:2:3 w p 755, 'p-756' u 1:2:3 w p 756, 'p-757' u 1:2:3 w p 757, 'p-758' u 1:2:3 w p 758, 'p-759' u 1:2:3 w p 759, 'p-760' u 1:2:3 w p 760, 'p-761' u 1:2:3 w p 761, 'p-762' u 1:2:3 w p 762, 'p-763' u 1:2:3 w p 763, 'p-764' u 1:2:3 w p 764, 'p-765' u 1:2:3 w p 765, 'p-766' u 1:2:3 w p 766, 'p-767' u 1:2:3 w p 767, 'p-768' u 1:2:3 w p 768, 'p-769' u 1:2:3 w p 769, 'p-770' u 1:2:3 w p 770, 'p-771' u 1:2:3 w p 771, 'p-772' u 1:2:3 w p 772, 'p-773' u 1:2:3 w p 773, 'p-774' u 1:2:3 w p 774, 'p-775' u 1:2:3 w p 775, 'p-776' u 1:2:3 w p 776, 'p-777' u 1:2:3 w p 777, 'p-778' u 1:2:3 w p 778, 'p-779' u 1:2:3 w p 779, 'p-780' u 1:2:3 w p 780, 'p-781' u 1:2:3 w p 781, 'p-782' u 1:2:3 w p 782, 'p-783' u 1:2:3 w p 783, 'p-784' u 1:2:3 w p 784, 'p-785' u 1:2:3 w p 785, 'p-786' u 1:2:3 w p 786, 'p-787' u 1:2:3 w p 787, 'p-788' u 1:2:3 w p 788, 'p-789' u 1:2:3 w p 789, 'p-790' u 1:2:3 w p 790, 'p-791' u 1:2:3 w p 791, 'p-792' u 1:2:3 w p 792, 'p-793' u 1:2:3 w p 793, 'p-794' u 1:2:3 w p 794, 'p-795' u 1:2:3 w p 795, 'p-796' u 1:2:3 w p 796, 'p-797' u 1:2:3 w p 797, 'p-798' u 1:2:3 w p 798, 'p-799' u 1:2:3 w p 799, 'p-800' u 1:2:3 w p 800, 'p-801' u 1:2:3 w p 801, 'p-802' u 1:2:3 w p 802, 'p-803' u 1:2:3 w p 803, 'p-804' u 1:2:3 w p 804, 'p-805' u 1:2:3 w p 805, 'p-806' u 1:2:3 w p 806, 'p-807' u 1:2:3 w p 807, 'p-808' u 1:2:3 w p 808, 'p-809' u 1:2:3 w p 809, 'p-810' u 1:2:3 w p 810, 'p-811' u 1:2:3 w p 811, 'p-812' u 1:2:3 w p 812, 'p-813' u 1:2:3 w p 813, 'p-814' u 1:2:3 w p 814, 'p-815' u 1:2:3 w p 815, 'p-816' u 1:2:3 w p 816, 'p-817' u 1:2:3 w p 817, 'p-818' u 1:2:3 w p 818, 'p-819' u 1:2:3 w p 819, 'p-820' u 1:2:3 w p 820, 'p-821' u 1:2:3 w p 821, 'p-822' u 1:2:3 w p 822, 'p-823' u 1:2:3 w p 823, 'p-824' u 1:2:3 w p 824, 'p-825' u 1:2:3 w p 825, 'p-826' u 1:2:3 w p 826, 'p-827' u 1:2:3 w p 827, 'p-828' u 1:2:3 w p 828, 'p-829' u 1:2:3 w p 829, 'p-830' u 1:2:3 w p 830, 'p-831' u 1:2:3 w p 831, 'p-832' u 1:2:3 w p 832, 'p-833' u 1:2:3 w p 833, 'p-834' u 1:2:3 w p 834, 'p-835' u 1:2:3 w p 835, 'p-836' u 1:2:3 w p 836, 'p-837' u 1:2:3 w p 837, 'p-838' u 1:2:3 w p 838, 'p-839' u 1:2:3 w p 839, 'p-840' u 1:2:3 w p 840, 'p-841' u 1:2:3 w p 841, 'p-842' u 1:2:3 w p 842, 'p-843' u 1:2:3 w p 843, 'p-844' u 1:2:3 w p 844, 'p-845' u 1:2:3 w p 845, 'p-846' u 1:2:3 w p 846, 'p-847' u 1:2:3 w p 847, 'p-848' u 1:2:3 w p 848, 'p-849' u 1:2:3 w p 849, 'p-850' u 1:2:3 w p 850, 'p-851' u 1:2:3 w p 851, 'p-852' u 1:2:3 w p 852, 'p-853' u 1:2:3 w p 853, 'p-854' u 1:2:3 w p 854, 'p-855' u 1:2:3 w p 855, 'p-856' u 1:2:3 w p 856, 'p-857' u 1:2:3 w p 857, 'p-858' u 1:2:3 w p 858, 'p-859' u 1:2:3 w p 859, 'p-860' u 1:2:3 w p 860, 'p-861' u 1:2:3 w p 861, 'p-862' u 1:2:3 w p 862, 'p-863' u 1:2:3 w p 863, 'p-864' u 1:2:3 w p 864, 'p-865' u 1:2:3 w p 865, 'p-866' u 1:2:3 w p 866, 'p-867' u 1:2:3 w p 867, 'p-868' u 1:2:3 w p 868, 'p-869' u 1:2:3 w p 869, 'p-870' u 1:2:3 w p 870, 'p-871' u 1:2:3 w p 871, 'p-872' u 1:2:3 w p 872, 'p-873' u 1:2:3 w p 873, 'p-874' u 1:2:3 w p 874, 'p-875' u 1:2:3 w p 875, 'p-876' u 1:2:3 w p 876, 'p-877' u 1:2:3 w p 877, 'p-878' u 1:2:3 w p 878, 'p-879' u 1:2:3 w p 879, 'p-880' u 1:2:3 w p 880, 'p-881' u 1:2:3 w p 881, 'p-882' u 1:2:3 w p 882, 'p-883' u 1:2:3 w p 883, 'p-884' u 1:2:3 w p 884, 'p-885' u 1:2:3 w p 885, 'p-886' u 1:2:3 w p 886, 'p-887' u 1:2:3 w p 887, 'p-888' u 1:2:3 w p 888, 'p-889' u 1:2:3 w p 889, 'p-890' u 1:2:3 w p 890, 'p-891' u 1:2:3 w p 891, 'p-892' u 1:2:3 w p 892, 'p-893' u 1:2:3 w p 893, 'p-894' u 1:2:3 w p 894, 'p-895' u 1:2:3 w p 895, 'p-896' u 1:2:3 w p 896, 'p-897' u 1:2:3 w p 897, 'p-898' u 1:2:3 w p 898, 'p-899' u 1:2:3 w p 899, 'p-900' u 1:2:3 w p 900, 'p-901' u 1:2:3 w p 901, 'p-902' u 1:2:3 w p 902, 'p-903' u 1:2:3 w p 903, 'p-904' u 1:2:3 w p 904, 'p-905' u 1:2:3 w p 905, 'p-906' u 1:2:3 w p 906, 'p-907' u 1:2:3 w p 907, 'p-908' u 1:2:3 w p 908, 'p-909' u 1:2:3 w p 909, 'p-910' u 1:2:3 w p 910, 'p-911' u 1:2:3 w p 911, 'p-912' u 1:2:3 w p 912, 'p-913' u 1:2:3 w p 913, 'p-914' u 1:2:3 w p 914, 'p-915' u 1:2:3 w p 915, 'p-916' u 1:2:3 w p 916, 'p-917' u 1:2:3 w p 917, 'p-918' u 1:2:3 w p 918, 'p-919' u 1:2:3 w p 919, 'p-920' u 1:2:3 w p 920, 'p-921' u 1:2:3 w p 921, 'p-922' u 1:2:3 w p 922, 'p-923' u 1:2:3 w p 923, 'p-924' u 1:2:3 w p 924, 'p-925' u 1:2:3 w p 925, 'p-926' u 1:2:3 w p 926, 'p-927' u 1:2:3 w p 927, 'p-928' u 1:2:3 w p 928, 'p-929' u 1:2:3 w p 929, 'p-930' u 1:2:3 w p 930, 'p-931' u 1:2:3 w p 931, 'p-932' u 1:2:3 w p 932, 'p-933' u 1:2:3 w p 933, 'p-934' u 1:2:3 w p 934, 'p-935' u 1:2:3 w p 935, 'p-936' u 1:2:3 w p 936, 'p-937' u 1:2:3 w p 937, 'p-938' u 1:2:3 w p 938, 'p-939' u 1:2:3 w p 939, 'p-940' u 1:2:3 w p 940, 'p-941' u 1:2:3 w p 941, 'p-942' u 1:2:3 w p 942, 'p-943' u 1:2:3 w p 943, 'p-944' u 1:2:3 w p 944, 'p-945' u 1:2:3 w p 945, 'p-946' u 1:2:3 w p 946, 'p-947' u 1:2:3 w p 947, 'p-948' u 1:2:3 w p 948, 'p-949' u 1:2:3 w p 949, 'p-950' u 1:2:3 w p 950, 'p-951' u 1:2:3 w p 951, 'p-952' u 1:2:3 w p 952, 'p-953' u 1:2:3 w p 953, 'p-954' u 1:2:3 w p 954, 'p-955' u 1:2:3 w p 955, 'p-956' u 1:2:3 w p 956, 'p-957' u 1:2:3 w p 957, 'p-958' u 1:2:3 w p 958, 'p-959' u 1:2:3 w p 959, 'p-960' u 1:2:3 w p 960, 'p-961' u 1:2:3 w p 961, 'p-962' u 1:2:3 w p 962, 'p-963' u 1:2:3 w p 963, 'p-964' u 1:2:3 w p 964, 'p-965' u 1:2:3 w p 965, 'p-966' u 1:2:3 w p 966, 'p-967' u 1:2:3 w p 967, 'p-968' u 1:2:3 w p 968, 'p-969' u 1:2:3 w p 969, 'p-970' u 1:2:3 w p 970, 'p-971' u 1:2:3 w p 971, 'p-972' u 1:2:3 w p 972, 'p-973' u 1:2:3 w p 973, 'p-974' u 1:2:3 w p 974, 'p-975' u 1:2:3 w p 975, 'p-976' u 1:2:3 w p 976, 'p-977' u 1:2:3 w p 977, 'p-978' u 1:2:3 w p 978, 'p-979' u 1:2:3 w p 979, 'p-980' u 1:2:3 w p 980, 'p-981' u 1:2:3 w p 981, 'p-982' u 1:2:3 w p 982, 'p-983' u 1:2:3 w p 983, 'p-984' u 1:2:3 w p 984, 'p-985' u 1:2:3 w p 985, 'p-986' u 1:2:3 w p 986, 'p-987' u 1:2:3 w p 987, 'p-988' u 1:2:3 w p 988, 'p-989' u 1:2:3 w p 989, 'p-990' u 1:2:3 w p 990, 'p-991' u 1:2:3 w p 991, 'p-992' u 1:2:3 w p 992, 'p-993' u 1:2:3 w p 993, 'p-994' u 1:2:3 w p 994, 'p-995' u 1:2:3 w p 995, 'p-996' u 1:2:3 w p 996, 'p-997' u 1:2:3 w p 997, 'p-998' u 1:2:3 w p 998, 'p-999' u 1:2:3 w p 999
