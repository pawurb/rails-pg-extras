/* The mandelbrot set */

WITH RECURSIVE Z(IX, IY, CX, CY, X, Y, I) AS (
          SELECT IX, IY, X::float, Y::float, X::float, Y::float, 0
          FROM (select -2.2 + 0.031 * i, i from generate_series(0,101) as i) as xgen(x,ix),
               (select -1.5 + 0.031 * i, i from generate_series(0,101) as i) as ygen(y,iy)
          UNION ALL
          SELECT IX, IY, CX, CY, X * X - Y * Y + CX AS X, Y * X * 2 + CY, I + 1
          FROM Z
          WHERE X * X + Y * Y < 16::float
          AND I < 100
    )
SELECT array_to_string(array_agg(SUBSTRING(' .,,,-----++++%%%%@@@@#### ', LEAST(GREATEST(I,1),27), 1)),'')
FROM (
      SELECT IX, IY, MAX(I) AS I
      FROM Z
      GROUP BY IY, IX
      ORDER BY IY, IX
     ) AS ZT
GROUP BY IY
ORDER BY IY;
