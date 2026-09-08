import json
from http.server import BaseHTTPRequestHandler, HTTPServer

PORT = 8000

APPROVAL_THRESHOLD = 500000

payments = [
    {"id": 1, "vendor": "Meridian Cloud Services", "ref": "INV-20430", "amount": 1875000, "due": "Wed 10 Sep", "status": "pending"},
    {"id": 2, "vendor": "Northwind Logistics", "ref": "INV-20418", "amount": 1240000, "due": "Tue 9 Sep", "status": "pending"},
    {"id": 3, "vendor": "Alder Legal LLP", "ref": "INV-20431", "amount": 730000, "due": "Thu 11 Sep", "status": "pending"},
    {"id": 4, "vendor": "Southgate Security", "ref": "INV-20440", "amount": 520000, "due": "Fri 12 Sep", "status": "pending"},
    {"id": 5, "vendor": "Peak Analytics", "ref": "INV-20441", "amount": 398000, "due": "Fri 12 Sep", "status": "pending"},
    {"id": 6, "vendor": "Corely Facilities", "ref": "INV-20419", "amount": 215000, "due": "Tue 9 Sep", "status": "pending"},
    {"id": 7, "vendor": "Fenwick Catering", "ref": "INV-20433", "amount": 149000, "due": "Thu 11 Sep", "status": "pending"},
    {"id": 8, "vendor": "Harbour Print Co", "ref": "INV-20422", "amount": 86000, "due": "Wed 10 Sep", "status": "pending"},
]


def money(cents):
    return "$" + format(cents / 100, ",.2f")


def needs_manager(p):
    return p["amount"] > APPROVAL_THRESHOLD


def find(pid):
    for p in payments:
        if p["id"] == pid:
            return p
    return None


def render():
    pending = [p for p in payments if p["status"] == "pending"]
    total = sum(p["amount"] for p in pending)
    flagged = len([p for p in pending if needs_manager(p)])
    approved = [p for p in payments if p["status"] == "approved"]
    approved_total = sum(p["amount"] for p in approved)

    rows = ""
    for p in payments:
        cls = "row"
        if p["status"] != "pending":
            cls = "row done"
        flag = ""
        if needs_manager(p):
            flag = '<span class="flag">manager approval</span>'
        if p["status"] == "pending":
            actions = (
                '<form method="POST" action="/decide" class="acts">'
                '<input type="hidden" name="id" value="' + str(p["id"]) + '">'
                '<button class="ap" name="what" value="approve">Approve</button>'
                '<button class="ho" name="what" value="hold">Hold</button>'
                "</form>"
            )
        else:
            actions = '<span class="stamp ' + p["status"] + '">' + p["status"] + "</span>"
        rows += (
            '<tr class="' + cls + '">'
            + "<td><strong>" + p["vendor"] + "</strong></td>"
            + '<td class="mut">' + p["ref"] + "</td>"
            + '<td class="mut">' + p["due"] + "</td>"
            + '<td class="amt">' + money(p["amount"]) + "</td>"
            + "<td>" + flag + "</td>"
            + '<td class="r">' + actions + "</td>"
            + "</tr>"
        )

    return """<!doctype html>
<html><head><meta charset="utf-8"><title>PayWise</title>
<style>
*{box-sizing:border-box}
body{margin:0;background:#F4F5F7;color:#1B1F24;font:16px/1.5 -apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif}
header{background:#fff;border-bottom:1px solid #D9DEE4;padding:22px 32px;display:flex;align-items:baseline;gap:14px}
h1{margin:0;font-size:22px;letter-spacing:-.01em}
.tag{color:#5B6472;font-size:15px}
.wrap{max-width:1180px;margin:0 auto;padding:28px 32px}
.cards{display:flex;gap:18px;margin-bottom:26px}
.card{background:#fff;border:1px solid #D9DEE4;border-radius:10px;padding:18px 22px;flex:1}
.card .n{font-size:30px;font-weight:700;letter-spacing:-.02em;font-variant-numeric:tabular-nums}
.card .l{color:#5B6472;font-size:14px;margin-top:2px}
.card.warn .n{color:#B45309}
table{width:100%;border-collapse:collapse;background:#fff;border:1px solid #D9DEE4;border-radius:10px;overflow:hidden}
th{text-align:left;font-size:12px;letter-spacing:.07em;text-transform:uppercase;color:#5B6472;font-weight:600;padding:14px 16px;border-bottom:1px solid #D9DEE4;background:#FAFBFC}
td{padding:15px 16px;border-bottom:1px solid #EDF0F3;vertical-align:middle}
tr:last-child td{border-bottom:0}
.row.done td{opacity:.45}
.mut{color:#5B6472}
.amt{text-align:right;font-weight:600;font-variant-numeric:tabular-nums;white-space:nowrap}
.r{text-align:right}
.flag{background:#FEF3C7;color:#92400E;border:1px solid #FDE68A;border-radius:99px;padding:4px 10px;font-size:12.5px;font-weight:600;white-space:nowrap}
.acts{display:flex;gap:8px;justify-content:flex-end;margin:0}
button{font:600 14px -apple-system,sans-serif;border-radius:6px;padding:9px 15px;cursor:pointer;border:1px solid transparent}
.ap{background:#15803D;color:#fff}
.ho{background:#fff;color:#5B6472;border-color:#D9DEE4}
.stamp{font-size:13px;font-weight:600;text-transform:capitalize}
.stamp.approved{color:#15803D}
.stamp.held{color:#B45309}
</style></head><body>
<header><h1>PayWise</h1><span class="tag">Vendor payments awaiting your decision</span></header>
<div class="wrap">
<div class="cards">
<div class="card"><div class="n">""" + str(len(pending)) + """</div><div class="l">pending decisions</div></div>
<div class="card"><div class="n">""" + money(total) + """</div><div class="l">total pending</div></div>
<div class="card warn"><div class="n">""" + str(flagged) + """</div><div class="l">need manager approval (over $5,000)</div></div>
<div class="card"><div class="n">""" + money(approved_total) + """</div><div class="l">approved so far</div></div>
</div>
<table>
<tr><th>Vendor</th><th>Reference</th><th>Due</th><th style="text-align:right">Amount</th><th>Policy</th><th></th></tr>
""" + rows + """
</table>
</div></body></html>"""


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/api/payments":
            body = json.dumps(payments).encode()
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(body)
            return
        body = render().encode()
        self.send_response(200)
        self.send_header("Content-Type", "text/html; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_POST(self):
        n = int(self.headers.get("Content-Length"))
        raw = self.rfile.read(n).decode()
        data = {}
        for part in raw.split("&"):
            if "=" in part:
                k, v = part.split("=", 1)
                data[k] = v
        p = find(int(data.get("id")))
        if p:
            if data.get("what") == "approve":
                p["status"] = "approved"
            else:
                p["status"] = "held"
        self.send_response(303)
        self.send_header("Location", "/")
        self.end_headers()

    def log_message(self, *args):
        pass


print("PayWise running on http://localhost:" + str(PORT))
HTTPServer(("127.0.0.1", PORT), Handler).serve_forever()
