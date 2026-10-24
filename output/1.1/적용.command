#!/bin/zsh
set -euo pipefail
cd -- "${0:A:h}"
command -v xdelta3 >/dev/null 2>&1 || { print 'xdelta3가 필요합니다. Homebrew: brew install xdelta'; exit 1; }
source_iso="${1:-}"
result_iso="${2:-}"
if [[ -z "$source_iso" ]]; then
  print '일본판 원본 ISO의 전체 경로를 입력하세요:'
  read -r source_iso
fi
if [[ -z "$result_iso" ]]; then
  print '새 결과 ISO의 전체 경로를 입력하세요 (기존 파일 덮어쓰기 금지):'
  read -r result_iso
fi
[[ -f "$source_iso" ]] || { print '원본 ISO를 찾을 수 없습니다.'; exit 1; }
[[ -n "$result_iso" && ! -e "$result_iso" && ! -L "$result_iso" ]] || { print '결과 경로가 비어 있거나 이미 존재합니다.'; exit 1; }
source_sha=$(shasum -a 256 "$source_iso" | awk '{print $1}')
[[ "$source_sha" == '6fb2c79197954c4170155d42b35834e5ef9c808d71c09e4ccec430fc01be6758' ]] || { print '지원 원본 SHA-256과 다릅니다. 일본판 원본 ISO에 적용하세요.'; exit 1; }
shasum -a 256 -c SHA256SUMS.txt
# 임시 결과는 출력 폴더에 생성하고, 검증한 뒤 덮어쓰기 없이 연결합니다.
result_tmp=$(mktemp "${result_iso}.partial.XXXXXX")
trap 'rm -f -- "$result_tmp"' EXIT
xdelta3 -d -c -s "$source_iso" 'GIREN_KOURYAKU_PS2_KO_1.1.xdelta' > "$result_tmp"
result_sha=$(shasum -a 256 "$result_tmp" | awk '{print $1}')
[[ "$result_sha" == '605aa86b07cf829d700ce1ff80b42c44691cd572543de817a82819fdf1c31b58' ]] || { print '결과 SHA-256이 다릅니다. 적용을 중단합니다.'; exit 1; }
ln -- "$result_tmp" "$result_iso"
print 'ver.1.1 적용 완료. 결과 ISO의 SHA-256이 일치합니다.'
