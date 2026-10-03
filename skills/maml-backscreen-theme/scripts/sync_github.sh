#!/system/bin/sh
# ============================================================
# MAML 背屏主题技能库 · GitHub 同步（设备无 git，走 REST API）
#
# 用法: sh sync_github.sh [分支] [仓库] 
#   例: sh sync_github.sh main wmqc97/MAML-Theme-Reference
#
# Token: 环境变量 GH_TOKEN > 文件 /storage/emulated/0/MiRoot/.github_token
# 默认目标: wmqc97/MAML-Theme-Reference (main)
#
# 依赖: curl / base64 / awk / od（设备自带，无需 git）
# ============================================================
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BRANCH="${1:-main}"
REPO="${2:-wmqc97/MAML-Theme-Reference}"
TOKEN="${GH_TOKEN:-$(cat /storage/emulated/0/MiRoot/.github_token 2>/dev/null)}"

[ -z "$TOKEN" ] && { echo "ERROR: 无 token。设 GH_TOKEN 或写入 /storage/emulated/0/MiRoot/.github_token"; exit 1; }
[ -d "$ROOT/references" ] || { echo "ERROR: 找不到 references/，脚本须放在 <skill>/scripts/ 下"; exit 1; }

API="https://api.github.com/repos/$REPO/contents"
REMOTE_BASE="skills/maml-backscreen-theme"    # 远端存放前缀

enc() { printf '%s' "$1" | od -An -v -tx1 | tr -d ' \n' | sed 's/\(..\)/%\1/g'; }
norm() { tr -d '\n\r' ; }

echo "repo=$REPO branch=$BRANCH"
echo "local=$ROOT"

up=0; new=0; sk=0; fail=0
LIST=/data/local/tmp/_gh_list.txt
find "$ROOT" -type f \( -name '*.md' -o -name '*.sh' \) | sort > "$LIST"
TOTAL=$(wc -l < "$LIST")
echo "files=$TOTAL"
echo

while read -r f; do
  rel="${f#$ROOT/}"
  api_path="$REMOTE_BASE/$rel"
  url="$API/$(enc "$api_path")"
  resp=$(curl -s -H "Authorization: token $TOKEN" "$url")
  sha=$(printf '%s' "$resp" | grep -oE '"sha": *"[a-f0-9]{40}"' | head -1 | cut -d'"' -f4)

  b64=$(base64 < "$f" | norm)
  old=$(printf '%s' "$resp" | grep -oE '"content": *"[^"]+"' | head -1 \
        | sed 's/.*"content": *"//;s/"$//' | tr -d '\n\r ' | sed 's/\\n//g;s/\\r//g')

  if [ -n "$sha" ] && [ "$old" = "$b64" ]; then
    echo "SKIP  $rel"; sk=$((sk+1)); continue
  fi

  printf '{"message":"docs: sync %s","content":"%s"%s}' \
    "$rel" "$b64" "$([ -n "$sha" ] && printf ',"sha":"%s"' "$sha")" > /data/local/tmp/_gh_body.json
  code=$(curl -s -o /dev/null -w "%{http_code}" -X PUT \
    -H "Authorization: token $TOKEN" -H "Accept: application/vnd.github+json" \
    --data-binary @/data/local/tmp/_gh_body.json "$url")

  case "$code" in
    200) echo "UPDT  $rel"; up=$((up+1));;
    201) echo "NEW   $rel"; new=$((new+1));;
    *)   echo "FAIL($code) $rel"; fail=$((fail+1));;
  esac
done < "$LIST"

rm -f "$LIST" /data/local/tmp/_gh_body.json 2>/dev/null
echo
echo "完成: 更新 $up / 新建 $new / 跳过 $sk / 失败 $fail"
echo "https://github.com/$REPO"
