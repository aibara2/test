CREATE OR REPLACE FUNCTION T0026.ZANSU_KB(
      		SYOUHINCD IN NUMBER,	--商品コード
      		NENGETSU IN NUMBER,	--年月
      		BUMONCD IN NUMBER, 	--部門
      		ZAIKOKB IN NUMBER 	--(0:ケース、1:バラ、2:ボール)
      		)RETURN NUMBER 		--残数
IS
	GETSUMATSU_SU_c NUMBER(10,0);
	GETSUMATSU_SU_b NUMBER(10,0);
	GETSUMATSU_SU_bo NUMBER(10,0);
	IKOUJI_YORYO_c  NUMBER(10,0);
	IKOUJI_YORYO_b  NUMBER(10,0);
BEGIN
	GETSUMATSU_SU_c:=0;
	GETSUMATSU_SU_b:=0;
	GETSUMATSU_SU_bo:=0;
	IKOUJI_YORYO_c:=0;
	IKOUJI_YORYO_b:=0;
	BEGIN
		SELECT
		SUM(NVL(当月入庫＿ケース,0)-NVL(当月出庫＿ケース,0) + NVL(過不足数量＿ケース,0)),--y.koba 過不足追加
		SUM(NVL(当月入庫＿ボール,0)-NVL(当月出庫＿ボール,0) + NVL(過不足数量＿ボール,0)),--y.koba 過不足追加
		SUM(NVL(当月入庫＿バラ,0)-NVL(当月出庫＿バラ,0) + NVL(過不足数量＿バラ,0))--y.koba 過不足追加
		INTO GETSUMATSU_SU_c,GETSUMATSU_SU_bo,GETSUMATSU_SU_b
		FROM AD商品別月間データ m,AD商品マスタ s
		WHERE 1=1
		AND 年月度 < NENGETSU
		AND m.商品コード = SYOUHINCD
		AND 部門コード = BUMONCD
		AND m.商品コード=s.商品コード
		;
	EXCEPTION WHEN NO_DATA_FOUND THEN
			GETSUMATSU_SU_c:=0;
			GETSUMATSU_SU_b:=0;
			GETSUMATSU_SU_bo:=0;
	end;
	if GETSUMATSU_SU_c is null then
			GETSUMATSU_SU_c:=0;
	end if;
	if GETSUMATSU_SU_b is null then
			GETSUMATSU_SU_b:=0;
	end if;
	if GETSUMATSU_SU_bo is null then
			GETSUMATSU_SU_bo:=0;
	end if;
	BEGIN
		SELECT NVL(移行時在庫数＿ケース,0),
		NVL(移行時在庫数＿バラ,0)
		INTO IKOUJI_YORYO_c,IKOUJI_YORYO_b
		FROM AD商品別初期データ m,AD商品マスタ s
		WHERE 1=1
		AND m.商品コード = SYOUHINCD
		AND m.商品コード = s.商品コード
		AND 部門コード = BUMONCD
	 	;
	EXCEPTION WHEN NO_DATA_FOUND THEN
			IKOUJI_YORYO_c:=0;
			IKOUJI_YORYO_b:=0;
	END;
	if IKOUJI_YORYO_c is null then
			IKOUJI_YORYO_c:=0;
	end if;
	if IKOUJI_YORYO_b is null then
			IKOUJI_YORYO_b:=0;
	end if;
 	if zaikokb = 0 then
		RETURN GETSUMATSU_SU_c + IKOUJI_YORYO_c;
 	elsif zaikokb = 1 then
		RETURN GETSUMATSU_SU_b + IKOUJI_YORYO_b;
 	else
		RETURN GETSUMATSU_SU_bo;
	end if;
END;
/
