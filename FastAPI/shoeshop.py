"""
author:team4
description:teamproject
date:2025/05/15
version:1.0
"""

from fastapi import FastAPI, UploadFile, File, Form
# 프론트에서 날아오는 데이터를 모두 하나의 Form으로 받는다. MODEL이 필요없다.
# 심지어 데이터를 나눠서 보낼 수 있다. FastAPI는 async니까.

from datetime import datetime, timedelta



from fastapi.responses import Response
# 이미지 검색해서 보여줄 때 씀

import pymysql
import json

app = FastAPI()
# 객체생성


# 오늘날짜, 어제 날자 구하는 코드
todaystr = f"{datetime.now().year}-{datetime.now().month:0>2}-{datetime.now().day:0>2}"
yesterday = datetime.now() - timedelta(days=1)
yesterdaystr = f"{yesterday.year}-{yesterday.month:0>2}-{yesterday.day:0>2}"



def connect():
  return pymysql.connect(
    host="127.0.0.1",
    user="root",
    password="qwer1234",
    db="shoeshop",
    charset="utf8"
  )

@app.post("/login") ## 로그인하기
async def login(cid: str = Form(...), cpassword: str = Form(...)):
    try:
        conn = connect()
        curs = conn.cursor()
        sql = "SELECT cname FROM customer WHERE cid = %s AND cpassword = %s"
        curs.execute(sql, (cid, cpassword))
        row = curs.fetchone()
        conn.close()

        if row:
            return {"result": "success", "cname": row[0]}
        else:
            return {"result": "fail"}
    except Exception as e:
        print("Login Error:", e)
        return {"result": "error", "message": str(e)}



@app.get("/check_customer_id") # 회원가입시 cid 로 중복 체크
async def check_customer_id(cid: str):
  try:
    conn = connect()
    curs = conn.cursor()
    sql = "SELECT * FROM customer WHERE cid = %s"
    curs.execute(sql, (cid,))
    row = curs.fetchone()
    conn.close()

    if row:
      return {"result": "exists"}  # 중복
    else:
      return {"result": "available"}  # 사용 가능
  except Exception as e:
    print("Error:", e)
    return {"result": "error"}
  


@app.post("/insert_customer") # 회원가입시 회원정보 insert
async def insert_customer(
  cid: str = Form(...),
  cname: str = Form(...),
  cpassword: str = Form(...),
  cphone: str = Form(...),
  cemail: str = Form(...),
  caddress: str = Form(...)
):
  try:
    conn = connect()
    curs = conn.cursor()
    sql = """
      INSERT INTO customer (cid, cname, cpassword, cphone, cemail, caddress)
      VALUES (%s, %s, %s, %s, %s, %s)
    """
    curs.execute(sql, (cid, cname, cpassword, cphone, cemail, caddress))
    conn.commit()
    conn.close()
    return {"result": "OK"}
  except Exception as e:
    print("Error:", e)
    return {"result": "Error"}
  

@app.get("/customer_info") # 회원정보 수정에서 회원정보를 select
async def customer_info(cid: str):
    try:
        conn = connect()
        curs = conn.cursor()
        sql = """
            SELECT cid, cname, cphone, cemail, caddress, ccardnum, ccardcvc, ccarddate
            FROM customer
            WHERE cid = %s
        """
        curs.execute(sql, (cid,))
        row = curs.fetchone()
        conn.close()

        if row:
            return {
                "cid": row[0],
                "cname": row[1],
                "cphone": row[2],
                "cemail": row[3],
                "caddress": row[4],
                "ccardnum": row[5],
                "ccardcvc": row[6],
                "ccarddate": row[7],
                "result": "OK"
            }
        else:
            return {"result": "NOT_FOUND"}
    except Exception as e:
        print("Error:", e)
        return {"result": "ERROR"}
  


@app.post("/update_customer") # 회원정보 수정에서 회원정보를 수정
async def update_customer(
    cid: str = Form(...),
    cname: str = Form(...),
    cphone: str = Form(...),
    cemail: str = Form(...),
    caddress: str = Form(...),
    ccardnum: str = Form(...),
    ccardcvc: int = Form(...),
    ccarddate: int = Form(...)
):
    try:
        conn = connect()
        curs = conn.cursor()
        sql = """
            UPDATE customer
            SET cname=%s, cphone=%s, cemail=%s, caddress=%s,
                ccardnum=%s, ccardcvc=%s, ccarddate=%s
            WHERE cid=%s
        """
        curs.execute(sql, (cname, cphone, cemail, caddress, ccardnum, ccardcvc, ccarddate, cid))
        conn.commit()
        conn.close()
        return {"result": "OK"}
    except Exception as e:
        print("Error:", e)
        return {"result": "ERROR"}


@app.get("/employee_list") # 대리점 목록을 불러오는 코드.
async def employee_list():
    try:
        conn = connect()
        curs = conn.cursor()
        sql = "SELECT eid, ename, elatdata, elongdata FROM employee WHERE epermission = 0 ORDER BY eid"
        curs.execute(sql)
        rows = curs.fetchall()
        conn.close()

        result = [{
            "eid": row[0],
            "ename": row[1],
            "lat": row[2],
            "lng": row[3]
        } for row in rows]

        return {"result": result}
    except Exception as e:
        print("Employee List Error:", e)
        return {"result": "Error"}
    
    
    

@app.post("/add_to_cart")  # 상품 상세 → 장바구니 추가
async def add_to_cart(
    cid: str = Form(...),
    pid: str = Form(...),
    count: int = Form(...),
    oeid: str = Form(...)
):
    try:
        conn = connect()
        curs = conn.cursor()
        sql = """
            INSERT INTO orders (ocid, opid, ocount, ostatus, ocartbool, oeid)
            VALUES (%s, %s, %s, '장바구니', 1, %s)
        """
        curs.execute(sql, (cid, pid, count, oeid))
        conn.commit()
        conn.close()
        return {"result": "OK"}
    except Exception as e:
        print("Error:", e)
        return {"result": "Error"}



@app.get("/cart_items") # 장바구니 내역을 보여주는 코드
async def cart_items(cid: str):
    try:
        conn = connect()
        curs = conn.cursor()
        sql = """
            SELECT o.oid, o.opid, o.ocount, o.oeid, e.ename,
                  p.pname, p.pprice, p.pcolor, p.psize
            FROM orders o
            JOIN product p ON o.opid = p.pid
            JOIN employee e ON o.oeid = e.eid
            WHERE o.ocid = %s AND o.ostatus = '장바구니' AND o.ocartbool = 1
        """
        curs.execute(sql, (cid,))
        rows = curs.fetchall()
        conn.close()

        result = [{
            "oid": row[0],
            "pid": row[1],
            "count": row[2],
            "oeid": row[3],
            "ename": row[4],
            "pname": row[5],
            "pprice": row[6],
            "pcolor": row[7],
            "psize": row[8],
            "image_url": f"http://127.0.0.1:8000/view/{row[1]}"
        } for row in rows]

        return {"result": result}
    except Exception as e:
        print("Error:", e)
        return {"result": "error"}


@app.delete("/delete_cart_item/{oid}") # 장바구니에서 선택내역 삭제하기
async def delete_cart_item(oid: int):
    try:
        conn = connect()
        curs = conn.cursor()
        sql = "DELETE FROM orders WHERE oid = %s"
        curs.execute(sql, (oid,))
        conn.commit()
        conn.close()
        return {"result": "OK"}
    except Exception as e:
        print("Error:", e)
        return {"result": "ERROR"}


@app.post("/buy_direct") # 단건구매
async def buy_direct(
    cid: str = Form(...),
    pid: str = Form(...),
    count: int = Form(...),
    oeid: str = Form(...)
):
    try:
        conn = connect()
        curs = conn.cursor()

        # 현재 재고 확인
        curs.execute("SELECT pstock FROM product WHERE pid = %s", (pid,))
        stock = curs.fetchone()[0]

        if stock < count:
            conn.close()
            return {"result": "FAIL", "message": "재고 부족"}

        # 재고 차감
        curs.execute("UPDATE product SET pstock = pstock - %s WHERE pid = %s", (count, pid))

        # 주문 추가
        curs.execute("""
            INSERT INTO orders (ocid, opid, ocount, ostatus, ocartbool, odate, oeid)
            VALUES (%s, %s, %s, '결제완료', 0, CURDATE(), %s)
        """, (cid, pid, count, oeid))

        conn.commit()
        conn.close()
        return {"result": "OK"}
    except Exception as e:
        print("BuyDirect Error:", e)
        return {"result": "Error", "message": str(e)}



@app.post("/buy_selected")  # 장바구니 → 선택 항목 다건 구매
async def buy_selected(items: str = Form(...), cid: str = Form(...)):
    try:
        items_list = json.loads(items)
        conn = connect()
        curs = conn.cursor()

        # 모든 재고 먼저 체크 (pname 포함해서 가져옴)
        for item in items_list:
            pid = item["pid"]
            count = item["count"]
            curs.execute("SELECT pstock, pname FROM product WHERE pid = %s", (pid,))
            row = curs.fetchone()
            stock, pname = row[0], row[1]

            if stock < count:
                conn.close()
                return {"result": "FAIL", "message": f"'{pname}' 상품의 재고가 부족합니다."}

        # 통과 시 재고 차감 및 주문 상태 변경
        for item in items_list:
            oid = item["oid"]
            pid = item["pid"]
            count = item["count"]
            oeid = item["oeid"]

            curs.execute("""
                UPDATE orders 
                SET ostatus = '결제완료', odate = CURDATE(), ocartbool = 0, oeid = %s
                WHERE oid = %s
            """, (oeid, oid))
            curs.execute("UPDATE product SET pstock = pstock - %s WHERE pid = %s", (count, pid))

        conn.commit()
        conn.close()
        return {"result": "OK"}
    except Exception as e:
        print("BuySelected Error:", e)
        return {"result": "Error", "message": str(e)}
    


@app.get("/order_list") # 사용자가 구매내역을 확인하는 코드
async def order_list(cid: str):
    try:
        conn = connect()
        curs = conn.cursor()
        sql = """
            SELECT o.oid, o.opid, o.ocount, o.odate, o.ostatus,
                  p.pname, p.pprice, p.pcolor, p.psize,
                  e.ename
            FROM orders o
            JOIN product p ON o.opid = p.pid
            LEFT JOIN employee e ON o.oeid = e.eid
            WHERE o.ocid = %s AND o.ostatus = '결제완료'
            ORDER BY o.odate DESC
        """
        curs.execute(sql, (cid,))
        rows = curs.fetchall()
        conn.close()

        result = [{
            "oid": row[0],
            "pid": row[1],
            "count": row[2],
            "odate": row[3],
            "ostatus": row[4],
            "pname": row[5],
            "pprice": row[6],
            "pcolor": row[7],
            "psize": row[8],
            "ename": row[9],
            "image_url": f"http://127.0.0.1:8000/view/{row[1]}"
        } for row in rows]

        return {"result": result}
    except Exception as e:
        print("Error:", e)
        return {"result": "error"}


@app.get("/returns") # 반품내역을 확인하는 코드
async def get_returns(cid: str):
    try:
        conn = connect()
        curs = conn.cursor()
        sql = """
            SELECT o.opid, o.ocount, o.oreturnstatus, o.odate,
                  p.pname, p.pprice, p.pcolor, p.psize
            FROM orders o
            JOIN product p ON o.opid = p.pid
            WHERE o.ocid = %s AND o.oreturnstatus IS NOT NULL AND o.oreturnstatus != ''
        """
        curs.execute(sql, (cid,))
        rows = curs.fetchall()
        conn.close()

        result = [{
            "pid": row[0],
            "count": row[1],
            "return_status": row[2],
            "date": row[3],
            "pname": row[4],
            "pprice": row[5],
            "pcolor": row[6],
            "psize": row[7],
        } for row in rows]

        return {"result": result}
    except Exception as e:
        print("Returns Error:", e)
        return {"result": "error"}
    



@app.get("/product_list")  # 상품 정보를 확인
async def product_list():
    try:
        conn = connect()
        curs = conn.cursor()
        curs.execute("SELECT pid, pname, pprice, pcolor, psize, pbrand, pstock FROM product ORDER BY pname")
        rows = curs.fetchall()
        conn.close()

        result = [{
            "pid": row[0],
            "pname": row[1],
            "pprice": row[2],
            "pcolor": row[3],
            "psize": row[4],
            "pbrand": row[5],
            "pstock": row[6],
            "image_url": f"http://127.0.0.1:8000/view/{row[0]}"
        } for row in rows]

        return {"result": result}
    except Exception as e:
        print("Error:", e)
        return {"result": "error", "message": str(e)}
    


@app.get("/view/{pid}") # 이미지를 보여주기
async def view(pid: str):
    try:
        conn = connect()
        curs = conn.cursor()
        curs.execute("SELECT pimage FROM product WHERE pid = %s", (pid,))
        row = curs.fetchone()
        conn.close()

        if row and row[0]:
            return Response(
                content=row[0],
                media_type="image/jpeg",
                headers={"Cache-Control": "no-cache, no-store, must-revalidate"}
            )
        else:
            return {"result": "No image found"}
    except Exception as e:
        print("Error:", e)
        return {"result": "Error"}



@app.post("/employee_login") # 관리자 로그인
async def employee_login(eid: str = Form(...), epassword: str = Form(...)):
    conn = connect()
    cursor = conn.cursor()
    cursor.execute("SELECT eid, ename, epermission FROM employee WHERE eid=%s AND epassword=%s", (eid, epassword))
    row = cursor.fetchone()
    conn.close()

    if row:
        return {
            "result": "success",
            "eid": row[0],
            "ename": row[1],
            "epermission": row[2]
        }
    else:
        return {"result": "fail"}
    
@app.get("/daily_revenue") # 관리자 페이지에서 일별 매출을 호출하는 코드
async def daily_revenue():
    conn = connect()
    cursor = conn.cursor()
    sql = """
        SELECT DATE(odate) as date, 
               SUM(pprice * ocount) as total
        FROM orders o
        JOIN product p ON o.opid = p.pid
        WHERE o.ostatus = '결제완료'
        GROUP BY DATE(odate)
        ORDER BY DATE(odate)
    """
    cursor.execute(sql)
    rows = cursor.fetchall()
    conn.close()
    result = [{"date": row[0], "total": row[1] or 0} for row in rows]
    return {"result": result}


@app.get("/dealer_revenue") # 관리자 페이지에서 지점별 매출을 호출하는 코드
def dealer_revenue(year: str, month: str):
    conn = connect()
    cursor = conn.cursor()
    sql = """
        SELECT e.ename, SUM(p.pprice * o.ocount) AS total
        FROM orders o
        JOIN employee e ON o.oeid = e.eid
        JOIN product p ON o.opid = p.pid
        WHERE o.ostatus = '결제완료'
          AND e.eid NOT IN ('h001', 'h002', 'h003')
          AND DATE_FORMAT(o.odate, '%%Y-%%m') = %s
        GROUP BY e.ename
        ORDER BY total DESC
    """
    ym = f"{year}-{month}"
    cursor.execute(sql, (ym,))
    rows = cursor.fetchall()
    conn.close()
    return {"result": [{"ename": row[0], "total": row[1] or 0} for row in rows]}


@app.get("/goods_revenue") # 관리자 페이지에서 상품별 매출을 호출하는 코드
def goods_revenue():
    conn = connect()
    cursor = conn.cursor()
    sql = """
        SELECT p.pname AS name, SUM(p.pprice * o.ocount) AS total
        FROM orders o
        JOIN product p ON o.opid = p.pid
        WHERE o.ostatus = '결제완료'
        GROUP BY p.pname
        ORDER BY total DESC
    """
    cursor.execute(sql)
    rows = cursor.fetchall()
    conn.close()
    return {"result": [{"name": row[0], "total": row[1] or 0} for row in rows]}

@app.get("/return_orders") # 관리자 페이지에서 반품내역을 표시하는 코드
def return_orders():
    conn = connect()
    cursor = conn.cursor()
    sql = """
        SELECT o.oid, o.opid, o.ocount, o.oreturncount, o.oreturndate, o.oreturnstatus,
              p.pbrand, p.pname, p.pcolor, p.psize
        FROM orders o
        JOIN product p ON o.opid = p.pid
        WHERE o.oreturncount IS NOT NULL AND o.oreturncount > 0
        ORDER BY o.oreturndate DESC
    """
    cursor.execute(sql)
    rows = cursor.fetchall()
    conn.close()
    return {"result": [
        {
            "oid": row[0], "opid": row[1], "ocount": row[2],
            "oreturncount": row[3], "oreturndate": str(row[4]),
            "oreturnstatus": row[5],
            "pbrand": row[6], "pname": row[7],
            "pcolor": row[8], "psize": row[9]
        } for row in rows
    ]}

#################### ADMIN파트

# 기안 리스트 생성용
@app.get("/a_select")
async def select():
    conn = connect()
    curs = conn.cursor()
    curs.execute("SELECT aid, astatus, pbrand, pname, pcolor, psize, abaljoo, adate, aeid, pstock FROM product, approval WHERE apid=pid ORDER BY aid")
    rows = curs.fetchall()
    conn.close()
    approval = [{'aid':row[0], 'astatus':row[1], 'pbrand':row[2], 'pname':row[3], 'pcolor':row[4], 'psize':row[5], 'abaljoo':row[6], 'adate':row[7], 'aeid':row[8], 'pstock':row[9]}for row in rows]
    return {'approvals':approval}

# 기안 개수
@app.get("/a_approval_count/{permission}")
async def select(permission: int):
    conn = connect()
    curs = conn.cursor()
    if (permission == 2):
        curs.execute('select count(*) from approval a where a.astatus = "대기"')
    elif (permission == 3):
        curs.execute('select count(*) from approval a where a.astatus = "팀장승인"')
    elif (permission == 1):
        curs.execute('select count(*) from approval a where a.astatus = "123"')
    conn.close()
    result = curs.fetchone()[0]
    return {'result':result}
# 반품 개수
@app.get("/a_return_count")
async def select():
    conn = connect()
    curs = conn.cursor()
    curs.execute('select count(*) from orders where oreturnstatus = "요청"')
    result = curs.fetchone()[0]
    conn.close()
    return {'result':result}
# 소량 상품 이름 리스트
@app.get("/a_low_prd_name")
async def select():
    conn = connect()
    curs = conn.cursor()
    curs.execute('select pid from product where pstock < 30')
    result = curs.fetchall()
    conn.close()
    return {'result':result}
# 소량 상품 디테일
@app.get("/a_low_prd_detail/{selectedproduct}")
async def select(selectedproduct:str):
    conn = connect()
    curs = conn.cursor()

    curs.execute('select p.pbrand, p.pname, p.pcolor, p.psize, p.pstock from product p where p.pid=%s',(selectedproduct,))
    result = curs.fetchall()[0]
    conn.close()
    return {'result':result}
    # else:
    #     curs.execute('select p.pbrand, p.pname, p.pcolor, p.psize, p.pstock from product p where p.pname=%s',('123123',))
    #     result = curs.fetchall()
    #     conn.close()
    #     return {'result':list(result)}
# 기안 추가
@app.post("/a_insert") #(...)은 required
async def insert(aeid: str=Form(...), abaljoo: int=Form(...), astatus: str=Form(...), apid: str=Form(...), adate: str=Form(...)):
    try:
        conn = connect()
        curs = conn.cursor()
        sql = "INSERT INTO approval (aeid, abaljoo, astatus, apid, adate) VALUES (%s, %s, %s, %s, %s)"
        curs.execute(sql, (aeid, abaljoo, astatus, apid, adate))
        conn.commit()
        conn.close()
        return {'result':'OK'}
    except Exception as e:
        print("Error:", e)
        return{"result":"Error"}

# 팀장 결재
@app.post("/a_update_2")
async def a_update_2(astatus: str = Form(...), ateamappdate: str = Form(...), aid: str = Form(...)):
    try:
        conn=connect()
        curs=conn.cursor()
        sql = "UPDATE approval SET astatus=%s, ateamappdate=%s WHERE aid=%s"
        curs.execute(sql, (astatus, ateamappdate, aid))
        conn.commit()
        conn.close()
        return {'result' : 'OK'}
    except Exception as e:
        print("Error :", e)
        return {'result' : 'Error'}
  
# 임원결재  
@app.post("/a_update_3")
async def a_update_3(astatus: str = Form(...), achiefappdate: str = Form(...), abaljoo: int = Form(...), aid: int = Form(...)):
    try:
        conn=connect()
        curs=conn.cursor()
        sql = "UPDATE approval, product SET astatus=%s, achiefappdate=%s, pstock = pstock + %s WHERE aid=%s and apid=pid"
        curs.execute(sql, (astatus, achiefappdate, abaljoo, aid))
        conn.commit()
        conn.close()
        return {'result' : 'OK'}
    except Exception as e:
        print("Error :", e)
        return {'result' : 'Error'}

# 반려(삭제)
@app.delete("/a_delete/{aid}")
async def delete(aid: int):
    try:
        conn=connect()
        curs=conn.cursor()
        curs.execute("DELETE FROM approval where aid = %s", (aid,))
        conn.commit()
        conn.close()
        return {'rewult':'OK'}
    except Exception as e:
        print("Error:", e)
        return {"result":"Error"}

# 소량 재고 수량
@app.get("/a_low_stock")
async def select():
    conn = connect()
    curs = conn.cursor()
    curs.execute("select count(*) from product where pstock < 30")
    result = curs.fetchone()[0]
    conn.close()
    return {'result':result}
# 오늘 총 매출
@app.get("/a_today_sales")
async def select():
    conn = connect()
    curs = conn.cursor()
    curs.execute("select sum(pprice*ocount) from product, orders where opid=pid and oreturncount IS NULL and odate=%s", (todaystr))
    result = curs.fetchone()[0]
    conn.close()
    return {'result':result}
# 어제 총 매출
@app.get("/a_yesterday_sales")
async def select():
    conn = connect()
    curs = conn.cursor()
    curs.execute("select sum(pprice*ocount) from product, orders where opid=pid and oreturncount IS NULL and odate=%s", (yesterdaystr))
    result = curs.fetchone()[0]
    conn.close()
    return {'result':result}


@app.get("/a_inventory") # 관리자 재고 현황 확인하기
async def a_inventory():
    try:
        conn = connect()
        curs = conn.cursor()
        curs.execute('SELECT pbrand, pname, psize, pcolor, pstock FROM product ORDER BY pbrand, pname')
        rows = curs.fetchall()
        conn.close()

        result = [
            {
            "pbrand":  row[0],
            "pname":   row[1],
            "psize":   row[2],
            "pcolor":  row[3],
            "pstock":  row[4],
            }
            for row in rows
        ]
        return {"result": result}

    except Exception as e:
        print('Error', e)
        return {'result': 'Error'}
    

@app.get("/a_inventory/low") # 관리자 재고 현황에서 30개 미만인 재고 순 체크하기
async def a_low_inventory(remain_stock: int = 30):
    try:
        conn = connect()
        curs = conn.cursor()
        curs.execute("""
            SELECT pbrand, pname, psize, pcolor, pstock
            FROM product
            WHERE pstock < %s
            ORDER BY pstock ASC
        """, (remain_stock,))
        rows = curs.fetchall()
        conn.close()

        result = [
            {
            "pbrand":  row[0],
            "pname":   row[1],
            "psize":   row[2],
            "pcolor":  row[3],
            "pstock":  row[4],
            }
            for row in rows
        ]
        return {'result':result}

    except Exception as e:
        print('Error', e)
        return {'result': 'Error'}


@app.post("/a_product_insert") # 관리자 상품 추가하기 
async def a_product_insert(
    pid: str = Form(...),
    pbrand: str = Form(...),
    pname: str = Form(...),
    psize: int = Form(...),
    pcolor: str = Form(...),
    pstock: int = Form(...),
    pprice: int = Form(...),
    pimage: UploadFile = File(...)
):
    try:
        conn = connect()
        curs = conn.cursor()
        image_bytes = await pimage.read()  # 이미지 바이너리

        sql = """
            INSERT INTO product (pid, pbrand, pname, psize, pcolor, pstock, pprice, pimage)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        """
        curs.execute(sql, (pid, pbrand, pname, psize, pcolor, pstock, pprice, image_bytes))
        conn.commit()
        conn.close()

        return {'result' : 'ok'}

    except Exception as e:
        print("Insert Error:", e)
        return {'result': 'Error', 'message': str(e)}
    

@app.get('/a_dealer_sales') # 지점별 어제/오늘 매출 비교
async def get_deler_sales():
    try:
        conn = connect()
        curs = conn.cursor()
        import datetime
        today = datetime.date.today()
        yesterday = today - datetime.timedelta(days=1)
        sql = """
            select
            e.ename,
            sum(case when date(o.odate) = %s then p.pprice * o.ocount else 0 end) as yesterday_sum,
            sum(case when date(o.odate) = %s then p.pprice * o.ocount else 0 end) as today_sum
            from orders o
            join product p on o.opid = p.pid
            join employee e on o.oeid = e.eid
            where o.ostatus = '결제완료'
            group by e.ename
            order by e.ename
            """
        curs.execute(sql, (yesterday, today))
        rows = curs.fetchall()
        conn.close()

        result = [
            {
                'ename': row[0],
                'yesterday': int(row[1]),
                'today': int(row[2]),
            } for row in rows
        ]
        return {'result': result}
    except Exception as e:
        print('sales_Error', e)
        return {'result':'Error'}
    

#################### ADMIN파트


#################### DEALER파트
@app.post("/update_return") # 딜러 리턴 페이지에 쓰는함수
async def update_return(oid: int = Form(...), oreturncount: int = Form(...), oreason: str = Form(...), oreturnstatus: str = Form(...), odefectivereason: str = Form(...), oreturndate: str = Form(...)):
    try:
        conn = connect()
        curs = conn.cursor()
        sql = "UPDATE orders SET oreturncount = %s, oreason = %s, oreturnstatus = %s, odefectivereason = %s, oreturndate = %s WHERE oid = %s"
        curs.execute(sql, (oreturncount, oreason, oreturnstatus, odefectivereason, oreturndate, oid))
        conn.commit()
        conn.close()
        return {"result": "OK"}
    except Exception as e:
        print("Error:", e)
        return {"result": "ERROR"}
@app.get('/list') # 딜러메인에 화면 구성
async def d_orders():
    try:
        conn = connect()
        curs = conn.cursor()
        curs.execute("SELECT oid, ocid, opid, oeid, ocount, odate, ostatus, oreturncount, oreturndate, oreturnstatus, oreason , p.pprice, p.pbrand , p.pname , odefectivereason FROM orders o JOIN product p ON o.opid = p.pid")
        rows = curs.fetchall()
        conn.close()
        return {"results": [{"oid": d[0], "ocid": d[1], "opid": d[2], "oeid": d[3], "ocount": d[4], "odate": d[5], "ostatus": d[6], "oreturncount": d[7], "oreturndate": d[8], "oreturnstatus": d[9], "oreason": d[10], "pprice" : d[11], "pbrand": d[12], "pname":d[13], "odefectivereason": d[14]} for d in rows]}
    except Exception as e:
        print("Error:", e)
        return {"result": f"Error: {str(e)}"}
    
@app.get('/dreturns') #딜러 리턴에 화면구성.
async def d_returns():
    try:
        conn = connect()
        curs = conn.cursor()
        curs.execute(
            "SELECT o.oid, o.opid, o.ocount, o.odate, o.oreturndate, o.oreturncount, "
            "o.oreturnstatus, o.oreason, o.odefectivereason, p.pname "
            "FROM orders o JOIN product p ON o.opid = p.pid "
            "WHERE o.oreturndate IS NOT NULL AND o.oreturndate != '' "
            "ORDER BY o.oreturndate DESC"
        )
        rows = curs.fetchall()
        conn.close()
        return {
            "results": [
                {
                    "oid": d[0],
                    "opid": d[1],
                    "ocount": d[2],
                    "odate": d[3],
                    "oreturndate": d[4],
                    "oreturncount": d[5],
                    "oreturnstatus": d[6],
                    "oreason": d[7],
                    "odefectivereason": d[8],
                    "pname": d[9],
                }
                for d in rows
            ]
        }
    except Exception as e:
        print("Error:", e)
        return {"result": f"Error: {str(e)}"}

    
@app.get('/district') #딜러쪽에 날짜표시.
async def d_district(eid: str):
    try:
        conn = connect()
        curs = conn.cursor()
        curs.execute("SELECT ename FROM employee WHERE eid = %s", (eid,))
        row = curs.fetchone()
        conn.close()
        if row:
            return {"ename": row[0]}
        else:
            return {"ename": ""}
    except Exception as e:
        print("Error:", e)
        return {"error": str(e)}





#################### DEALER파트

####################
# 파이썬 메인 함수
if __name__ == "__main__":
  import uvicorn
  uvicorn.run(app, host="127.0.0.1", port=8000)


  