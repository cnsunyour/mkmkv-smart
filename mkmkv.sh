#!/usr/bin/env bash

# 检查是否安装了 mkvmerge
# 如果没有安装，退出脚本
if ! command -v mkvmerge &>/dev/null; then
  echo "mkvmerge not found, please install mkvtoolnix"
  exit 1
fi

# 所有语言代码和语言名称的映射
declare -A lang_map=(
  ["aa"]="Afar"
  ["ab"]="ქართული"
  ["ae"]="Avestan"
  ["af"]="Afrikaans"
  ["af-ZA"]="Afrikaans (South Africa)"
  ["ak"]="Akan"
  ["am"]="አማርኛ"
  ["am-ET"]="አማርኛ (ኢትዮጵያ)"
  ["an"]="Aragonese"
  ["ar"]="العربية"
  ["ar-001"]="العربية"
  ["ar-AE"]="العربية (الإمارات العربية المتحدة)"
  ["ar-AR"]="العربية"
  ["ar-BH"]="العربية (البحرين)"
  ["ar-DZ"]="العربية (الجزائر)"
  ["ar-EG"]="العربية (مصر)"
  ["ar-IQ"]="العربية (العراق)"
  ["ar-JO"]="الأردن"
  ["ar-KW"]="الكويت"
  ["ar-LB"]="لبنان"
  ["ar-LY"]="ليبيا"
  ["ar-MA"]="المغرب"
  ["ar-OM"]="عمان"
  ["ar-QA"]="قطر"
  ["ar-SA"]="المملكة العربية السعودية"
  ["ar-SY"]="سوريا"
  ["ar-TN"]="تونس"
  ["ar-YE"]="اليمن"
  ["as"]="অসমীয়া"
  ["av"]="Avaric"
  ["ay"]="Aymar aru"
  ["az-AZ"]="Azərbaycan dili (Azərbaycan)"
  ["az"]="Azərbaycan dili"
  ["ba"]="Башҡорт теле"
  ["be"]="Беларуская"
  ["be-BY"]="Беларуская (Беларусь)"
  ["bg"]="български"
  ["bg-BG"]="български (България)"
  ["bh"]="Bihari"
  ["bi"]="Bislama"
  ["bm"]="Bamanankan"
  ["bn"]="বাংলা"
  ["bn-BD"]="বাংলা (বাংলাদেশ)"
  ["bn-IN"]="বাংলা (ভারত)"
  ["bo"]="བོད་སྐད་"
  ["br"]="Brezhoneg"
  ["bs-BA"]="Bosanski (Bosna i Hercegovina)"
  ["bs"]="Bosanski"
  ["ca"]="Català"
  ["ca-ES"]="Català (Espanya)"
  ["ca-ES-valencia"]="Català (València)"
  ["ce"]="Нохчийн мотт"
  ["ch"]="Chamoru"
  ["co"]="Corsu"
  ["cr"]="Nēhiyawēwin"
  ["cs"]="čeština"
  ["cs-CZ"]="čeština (Česká republika)"
  ["cv"]="Чӑваш чӗлхи"
  ["cy"]="Cymraeg"
  ["cy-GB"]="Cymraeg (y Deyrnas Unedig)"
  ["da"]="dansk"
  ["da-DK"]="dansk (Danmark)"
  ["de-AT"]="Deutsch (Österreich)"
  ["de-CH"]="Deutsch (Schweiz)"
  ["de-DE"]="Deutsch (Deutschland)"
  ["de"]="Deutsch"
  ["de-LI"]="Deutsch (Liechtenstein)"
  ["de-LU"]="Deutsch (Luxemburg)"
  ["dv"]="ދިވެހިބަސް"
  ["dv-MV"]="ދިވެހިބަސް (Maldives)"
  ["dz"]="རྫོང་ཁ"
  ["ee"]="Eʋegbe"
  ["el"]="Ελληνικά"
  ["el-GR"]="Ελληνικά (Ελλάδα)"
  ["en-AU"]="English (Australia)"
  ["en-BZ"]="English (Belize)"
  ["en-CA"]="English (Canada)"
  ["en-CB"]="English (Caribbean)"
  ["en"]="English"
  ["en-GB"]="English (United Kingdom)"
  ["en-IE"]="English (Ireland)"
  ["en-IN"]="English (India)"
  ["en-JM"]="English (Jamaica)"
  ["en-NG"]="English (Nigeria)"
  ["en-NZ"]="English (New Zealand)"
  ["en-PH"]="English (Philippines)"
  ["en-SG"]="English (Singapore)"
  ["en-TT"]="English (Trinidad and Tobago)"
  ["en-US"]="English (United States)"
  ["en-ZA"]="English (South Africa)"
  ["en-ZW"]="English (Zimbabwe)"
  ["eo"]="Esperanto"
  ["es-419"]="español (de América Latina)"
  ["es-AR"]="español (Argentina)"
  ["es-BO"]="español (Bolivia)"
  ["es-CL"]="español (Chile)"
  ["es-CO"]="español (Colombia)"
  ["es-CR"]="español (Costa Rica)"
  ["es-DO"]="español (República Dominicana)"
  ["es-EC"]="español (Ecuador)"
  ["es-ES"]="español (España)"
  ["es"]="español"
  ["es-GT"]="español (Guatemala)"
  ["es-HN"]="español (Honduras)"
  ["es-LA"]="español (de América Latina)"
  ["es-MX"]="español (México)"
  ["es-NI"]="español (Nicaragua)"
  ["es-PA"]="español (Panamá)"
  ["es-PE"]="español (Perú)"
  ["es-PR"]="español (Puerto Rico)"
  ["es-PY"]="español (Paraguay)"
  ["es-SV"]="español (El Salvador)"
  ["es-UY"]="español (Uruguay)"
  ["es-VE"]="español (Venezuela)"
  ["et-EE"]="eesti (Eesti)"
  ["et"]="eesti"
  ["eu-ES"]="euskara (Espainia)"
  ["eu"]="euskara"
  ["fa"]="فارسی"
  ["fa-IR"]="فارسی (ایران)"
  ["ff"]="Pulaar"
  ["fi-FI"]="suomi (Suomi)"
  ["fil"]="Filipino"
  ["fil-PH"]="Filipino (Pilipinas)"
  ["fil-PR"]="Filipino (Puerto Rico)"
  ["fi"]="suomi"
  ["fj"]="Na Vosa Vakaviti"
  ["fo-FO"]="føroyskt (Føroyar)"
  ["fo"]="føroyskt"
  ["fr-BE"]="français (Belgique)"
  ["fr-CA"]="français (Canada)"
  ["fr-CH"]="français (Suisse)"
  ["fr"]="français"
  ["fr-FR"]="français (France)"
  ["fr-LU"]="français (Luxembourg)"
  ["fr-MC"]="français (Monaco)"
  ["fy"]="Frysk"
  ["ga"]="Gaeilge"
  ["gd"]="Gàidhlig"
  ["gl-ES"]="galego (España)"
  ["gl"]="galego"
  ["gn"]="Avañe'ẽ"
  ["gu"]="ગુજરાતી"
  ["gu-IN"]="ગુજરાતી (ભારત)"
  ["gv"]="Gaelg"
  ["ha"]="Hausa"
  ["he"]="עברית"
  ["he-IL"]="עברית (ישראל)"
  ["hi"]="हिन्दी"
  ["hi-IN"]="हिन्दी (भारत)"
  ["hr-BA"]="hrvatski (Bosna i Hercegovina)"
  ["hr-HR"]="hrvatski (Hrvatska)"
  ["hr"]="hrvatski"
  ["ht"]="Kreyòl ayisyen"
  ["hu-HU"]="magyar (Magyarország)"
  ["hu"]="magyar"
  ["hy"]="հայերեն"
  ["hy-AM"]="հայերեն (Հայաստան)"
  ["id"]="Bahasa Indonesia"
  ["id-ID"]="Bahasa Indonesia (Indonesia)"
  ["ii"]="ꆇꉙ"
  ["ik"]="Iñupiaq"
  ["ilo"]="Iloko"
  ["in"]="Bahasa Indonesia"
  ["is-IS"]="íslenska (Ísland)"
  ["is"]="íslenska"
  ["it-CH"]="italiano (Svizzera)"
  ["it"]="italiano"
  ["it-IT"]="italiano (Italia)"
  ["ja"]="日本語"
  ["jv"]="Basa Jawa"
  ["ka"]="ქართული"
  ["kk"]="Қазақ тілі"
  ["kk-KZ"]="қазақ (Қазақстан)"
  ["kl"]="Kalaallisut"
  ["km"]="ភាសាខ្មែរ"
  ["km-KH"]="ភាសាខ្មែរ (កម្ពុជា)"
  ["kn"]="ಕನ್ನს"
  ["kn-IN"]="ಕನ್ನಡ (ಭಾರત)"
  ["ko"]="한국어"
  ["kok"]="कोंकणी"
  ["kok-IN"]="कोंकणी (भारत)"
  ["ko-KR"]="한국어 (대한민국)"
  ["ks"]="کٲشُر"
  ["ku"]="Kurdî"
  ["kv"]="Коми кыв"
  ["kw"]="Kernewek"
  ["ky"]="кыргызча"
  ["ky-KG"]="кыргызча (Кыргызстан)"
  ["la"]="Latina"
  ["lb"]="Lëtzebuergesch"
  ["le"]="Lezgi"
  ["li"]="Limburgs"
  ["ln"]="Lingála"
  ["lo"]="ພາສາລາວ"
  ["lt"]="lietuvių"
  ["lt-LT"]="lietuvių (Lietuva)"
  ["lv"]="latviešu"
  ["lv-LV"]="latviešu (Latvija)"
  ["mg"]="Malagasy"
  ["mh"]="Kajin M̧ajeļ"
  ["mi-NZ"]="te reo Māori (Aotearoa)"
  ["mi"]="te reo Māori"
  ["mk"]="македонски"
  ["mk-MK"]="македонски (Македонија)"
  ["ml"]="മലയാളം"
  ["ml-in"]="മലയാളം (ഇന്ത്യ)"
  ["mn"]="монгол"
  ["mn-MN"]="монгол (Монгол улс)"
  ["mo"]="Молдовеняскэ"
  ["mr"]="मराठी"
  ["mr-IN"]="मराठी (भारत)"
  ["ms"]="Bahasa Melayu"
  ["ms-BN"]="Bahasa Melayu (Brunei)"
  ["ms-MY"]="Bahasa Melayu (Malaysia)"
  ["mt"]="Malti"
  ["mt-MT"]="Malti (Malta)"
  ["my"]="မြန်မာ"
  ["my-MM"]="မြန်မာ (မြန်မာ)"
  ["na"]="Ekakairũ Naoero"
  ["nb-NO"]="norsk bokmål (Norge)"
  ["nb"]="norsk bokmål"
  ["nd"]="isiNdebele"
  ["ne"]="नेपाली"
  ["ne-IN"]="नेपाली (भारत)"
  ["ne-NP"]="नेपाली (नेपाल)"
  ["nl-BE"]="Nederlands (België)"
  ["nl"]="Nederlands"
  ["nl-NL"]="Nederlands (Nederland)"
  ["nn-NO"]="norsk nynorsk (Norge)"
  ["nn"]="norsk nynorsk"
  ["no-NO"]="norsk (Norge)"
  ["no"]="norsk"
  ["nr"]="isiNdebele"
  ["ns"]="Sesotho"
  ["ns-ZA"]="Sesotho (South Africa)"
  ["nv"]="Diné bizaad"
  ["ny"]="Chichewa"
  ["oc"]="Occitan"
  ["oj"]="Anishinaabemowin"
  ["or"]="ଓଡ଼ିଆ"
  ["os"]="Ирон æвзаг"
  ["pa"]="ਪੰਜਾਬੀ"
  ["pa-IN"]="ਪੰਜਾਬੀ (ਭਾਰਤ)"
  ["pi"]="पालि"
  ["pl-PL"]="polski (Polska)"
  ["pl"]="polski"
  ["pt-BR"]="português (Brasil)"
  ["pt"]="português"
  ["pt-PT"]="português (Portugal)"
  ["qu-BO"]="Runa Simi (Bolivia)"
  ["qu-EC"]="Runa Simi (Ecuador)"
  ["qu-PE"]="Runa Simi (Perú)"
  ["qu"]="Runa Simi"
  ["rm"]="Rumantsch"
  ["rn"]="Ikirundi"
  ["ro"]="română"
  ["ro-RO"]="română (România)"
  ["ru"]="русский"
  ["ru-RU"]="русский (Россия)"
  ["rw"]="Ikinyarwanda"
  ["sa"]="संस्कृतम्"
  ["sa-IN"]="संस्कृतम् (भारतम्)"
  ["sc"]="Sardu"
  ["sd"]="سنڌي"
  ["se"]="davvisámegiella"
  ["se-FI"]="davvisámegiella (Suopma)"
  ["se-NO"]="davvisámegiella (Norga)"
  ["se-SE"]="davvisámegiella (Ruoŧŧa)"
  ["sg"]="Sängö"
  ["sh"]="Srpskohrvatski"
  ["si"]="සිංහල"
  ["si-LK"]="සිංහල (ශ්රී ලංකා)"
  ["sk-SK"]="slovenčina (Slovensko)"
  ["sk"]="slovenčina"
  ["sl-SI"]="slovenščina (Slovenija)"
  ["sl"]="slovenščina"
  ["so"]="Soomaaliga"
  ["sq-AL"]="shqip (Shqipëria)"
  ["sq"]="shqip"
  ["sr-BA"]="српски (Босна и Херцеговина)"
  ["sr-RS"]="српски (Република Србија)"
  ["sr-SP"]="српски (Србија)"
  ["ss"]="SiSwati"
  ["st"]="Sesotho"
  ["sv-FI"]="svenska (Finland)"
  ["sv-SE"]="svenska (Sverige)"
  ["sv"]="svenska"
  ["sw-KE"]="Kiswahili (Kenya)"
  ["sw"]="Kiswahili"
  ["syr"]="ܣܘܪܝܝܐ"
  ["syr-SY"]="ܣܘܪܝܝܐ (ܣܘܪܝܐ)"
  ["ta"]="தமிழ்"
  ["ta-IN"]="தமிழ் (இந்தியா)"
  ["te"]="తెలుగు"
  ["te-IN"]="తెలుగు (భారతదేశం)"
  ["tg"]="Тоҷикӣ"
  ["th"]="ไทย"
  ["th-TH"]="ไทย (ไทย)"
  ["tk"]="Türkmençe"
  ["tl"]="Filipino"
  ["tl-PH"]="Filipino (Pilipinas)"
  ["tn"]="Setswana"
  ["tn-ZA"]="Setswana (Aforika Borwa)"
  ["to"]="Lea Fakatonga"
  ["tr-TR"]="Türkçe (Türkiye)"
  ["tr"]="Türkçe"
  ["ts"]="Xitsonga"
  ["tt"]="Татар теле"
  ["tt-RU"]="Татарча (Россия)"
  ["tv"]="Te Gana Tuvalu"
  ["ug"]="ئۇيغۇر تىلى"
  ["uk"]="українська"
  ["uk-UA"]="українська (Україна)"
  ["ur"]="اردو"
  ["ur-PK"]="اردو (پاکستان)"
  ["uz"]="o'zbek"
  ["uz-UZ"]="o'zbek (Oʻzbekiston)"
  ["ve"]="Tshivenḓa"
  ["vi"]="Tiếng Việt"
  ["vi-VI"]="Tiếng Việt (Việt Nam)"
  ["vi-VN"]="Tiếng Việt (Việt Nam)"
  ["vo"]="Volapük"
  ["wo"]="Wolof"
  ["xh"]="isiXhosa"
  ["xh-ZA"]="isiXhosa (South Africa)"
  ["yi"]="ייִדיש"
  ["yo"]="Yorùbá"
  ["za"]="Vahcuengh"
  ["zh"]="中文"
  ["zh-CN"]="中文 (中国)"
  ["zh-Hans"]="简体中文"
  ["zh-Hant"]="繁體中文"
  ["zh-HK"]="中文 (香港)"
  ["zh-MO"]="中文 (澳门)"
  ["zh-SG"]="中文 (新加坡)"
  ["zh-TW"]="中文 (台灣)"
  ["zu"]="isiZulu"
  ["zu-ZA"]="isiZulu (South Africa)"
)
# 对所有键值进行小写化复制，以解决文件判断时的大小写问题
for lang in "${!lang_map[@]}"; do
  if [ "${lang,,}" != "$lang" ]; then
    lang_map[${lang,,}]=${lang_map[$lang]}
  fi
done

# 预定义需要优先处理的字幕语言代码
preset_lang_codes=(zh zh-hans zh-hant zh-cn zh-hk zh-mo zh-tw zh-sg en en-us en-gb en-au en-ca en-nz en-sg en-bz en-cb en-ie en-in en-jm en-ng en-ph en-tt en-za en-zw)

# 字幕类型
# subtitle_types=('' 'cc' 'sdh' 'forced' 'forced[narrative]')
# declare -A subtitle_type_names=(['sdh']='CC' ['forced']='Forced' ['forced[narrative]']='Forced')
subtitle_types=('' 'cc' 'sdh')
declare -A subtitle_type_names=(['sdh']='CC')

# 统计变量（全局）
total_files=0
success_files=0
failed_files=0

# 处理第一个参数，存在则将其作为源路径，否则以当前路径为源路径
if [ $# -ge 1 ] && [ -d "$1" ]; then
  source_dir=$(cd "$1" && pwd)
else
  source_dir=$(pwd)
fi
# 处理第二个参数，存在则将其作为目的路径，否则以源路径为目的路径
if [ $# -ge 2 ] && [ -d "$2" ]; then
  target_dir=$(cd "$2" && pwd)
else
  target_dir="$source_dir"
fi

# 处理第三个及之后的参数，作为 mkvmerge 的附加参数（安全过滤）
if [ $# -ge 3 ]; then
  mkvcmd_params=()
  # 从第三个参数开始遍历
  shift 2
  for param in "$@"; do
    # 安全过滤：检查是否包含危险字符
    if echo "$param" | grep -qE '[;`$|&>|\\]'; then
      echo "错误：参数包含非法字符（分号、反引号、\$、管道、重定向、反斜杠）"
      echo "问题参数：$param"
      exit 1
    fi
    mkvcmd_params+=("$param")
  done
fi

# 根据操作系统类型设置 find 命令参数
if [ "$(uname)" == "Darwin" ]; then
  find_param="-s"
else
  find_param=""
fi

# 获取 Bash 主要版本号和次要版本号
major_version=$(echo "$BASH_VERSION" | cut -d '.' -f 1)
minor_version=$(echo "$BASH_VERSION" | cut -d '.' -f 2)

# 处理函数（在子shell中执行）
process_files() {
  local source_dir="$1"
  local target_dir="$2"
  local find_param="$3"
  shift 3
  local extra_params=("$@")

  # 使用临时文件传递统计结果
  local stats_file
  stats_file=$(mktemp)
  
  # 默认 IFS 分隔符为空格，对于文件名有空格的会出错，这里以换行符为分隔符
  IFS=$'\n'
  
  # 初始化统计
  echo "0 0 0" > "$stats_file"
  
  # 遍历处理源路径中的所有 mp4 文件，不包括子目录
  while IFS= read -r file; do
    [ -z "$file" ] && continue
    # 取文件基本名称
    filename=$(basename "$file")
    matchname=${filename%.*}

    # 判断版本是否大于等于 5.2
    if [[ $major_version -gt 5 ]] || [[ $major_version -eq 5 && $minor_version -ge 2 ]]; then
      # 在 5.2 以上版本执行的操作
      # 字符串替换中的 & 符号是 bash 5.2 的特性
      matchname=${matchname//[\[\]\*\?]/\\&}
    else
      # 在 5.2 以下版本执行的操作
      matchname=${matchname//\[/\\[}
      matchname=${matchname//\]/\\]}
      matchname=${matchname//\*/\\*}
      matchname=${matchname//\?/\\?}
    fi

    declare -A srt_valid=()
    lang_valid=()
    # 遍历当前 mp4 对应的所有字幕文件
    while IFS= read -r tmp_srt; do
      [ -z "$tmp_srt" ] && continue
      # 用正则表达式匹配字幕文件名，匹配成功则将其加入有效字幕列表，为了大小写不敏感，这里将字符转换为小写后再进行匹配
      if [[ "${tmp_srt,,}" =~ [.-_]([a-z]{2,3}([-_][a-z0-9]{2,})?)([.-_\[](cc|sdh|forced(\[narrative\])?)\]?)?\.(srt|ass)$ ]]; then
        tmp_srt_lang=${BASH_REMATCH[1],,}
        tmp_srt_type=${BASH_REMATCH[4],,}
        if [ "${lang_map[$tmp_srt_lang]}" == "" ]; then
          echo "lang $tmp_srt_lang is unknown."
          rm -f "$stats_file"
          exit 1
        fi
        srt_valid["${tmp_srt_lang}.${tmp_srt_type}"]="$tmp_srt"
        lang_valid+=("$tmp_srt_lang")
        # 清除字幕中的字体格式标签（使用临时文件）
        extname=${tmp_srt##*.}
        if [ "${extname,,}" == "srt" ]; then
          # 使用临时文件，不直接修改原文件
          temp_srt="${tmp_srt}.tmp"
          if sed 's/<[^>]*>//g' "$tmp_srt" > "$temp_srt" 2>/dev/null; then
            mv "$temp_srt" "$tmp_srt"
          else
            rm -f "$temp_srt"
          fi
        fi
      else
        echo "$tmp_srt is not a valid subtitle filename."
      fi
    done < <(find "$source_dir" -maxdepth 1 -type f \( -iname "${matchname}*.srt" -o -iname "${matchname}*.ass" \))

    # 生成有效字幕语言代码列表
    lang_codes=()
    for lang in "${preset_lang_codes[@]}"; do
      # 检查 lang 是否在 lang_valid 数组中
      found=false
      for valid_lang in "${lang_valid[@]}"; do
        if [ "$valid_lang" == "$lang" ]; then
          found=true
          break
        fi
      done
      if $found; then
        lang_codes+=("$lang")
      fi
    done
    # 添加未包含在 preset 中的语言
    for lang in "${lang_valid[@]}"; do
      found=false
      for existing in "${lang_codes[@]}"; do
        if [ "$existing" == "$lang" ]; then
          found=true
          break
        fi
      done
      if ! $found; then
        lang_codes+=("$lang")
      fi
    done

    # 构建 mkvmerge 命令数组
    mkmkvcmd_arr=("mkvmerge" "-o" "$target_dir/${filename%.*}.mkv" "-S" "--no-global-tags" "$file")

    # 是否已经为当前文件设置过 default flag ，初始为 no
    # 一旦设置过 default flag ，则此值必须同时设为非 no
    # 目的是确保每一个生成的 mkv 文件只有一个字幕流为默认流
    have_default="no"

    # 遍历语言代码
    for lang_code in "${lang_codes[@]}"; do
      # 循环处理字幕类型，用这种循环方式遍历数组是因为要处理空元素
      for ((i = 0; i < ${#subtitle_types[@]}; i++)); do
        subtitle_type=${subtitle_types[$i]}
        # 取扩展字幕类型对应的名称，用于设置 track name
        if [ "$subtitle_type" == "" ]; then
          subtitle_type_name=""
        elif [ "${subtitle_type_names[$subtitle_type]}" != "" ]; then
          subtitle_type_name=" [${subtitle_type_names[$subtitle_type]}]"
        else
          subtitle_type_name=" [${subtitle_type^^}]"
        fi

        # 判断文件是否存在
        srt_file=${srt_valid["${lang_code}.${subtitle_type}"]}
        if [ "$srt_file" != "" ]; then
          # 设置 degault flag ，确保一个文件只有一条默认字幕流
          if [ $have_default == "no" ]; then
            default_flag="yes"
            have_default="yes"
          else
            default_flag="no"
          fi
          # 添加到命令数组
          mkmkvcmd_arr+=("--sub-charset" "0:UTF-8" "--language" "0:$lang_code" "--track-name" "0:${lang_map[$lang_code]}$subtitle_type_name" "--default-track-flag" "0:$default_flag" "$srt_file")
        fi
      done
    done

    # 拼接附加参数（已通过安全过滤）
    if [ ${#extra_params[@]} -gt 0 ]; then
      for param in "${extra_params[@]}"; do
        mkmkvcmd_arr+=("$param")
      done
    fi

    # 执行 mkvmerge
    local total success failed
    read -r total success failed < "$stats_file"
    total=$((total + 1))
    echo "[$total] 处理: $filename"
    if "${mkmkvcmd_arr[@]}" --quiet 2>&1; then
      success=$((success + 1))
    else
      failed=$((failed + 1))
      echo "  错误: 处理失败"
    fi
    echo "$total $success $failed" > "$stats_file"
  done < <(find "$find_param" "$source_dir" -maxdepth 1 -type f \( -iname "*.mp4" ! -iname ".*" \))
  
  # 输出最终统计结果
  cat "$stats_file"
  rm -f "$stats_file"
}

# 调用处理函数并获取统计结果
read -r total_files success_files failed_files < <(process_files "$source_dir" "$target_dir" "$find_param" "${mkvcmd_params[@]}")

# 输出统计信息
echo ""
echo "======================================"
echo "处理完成:"
echo "  总计: $total_files 个文件"
echo "  成功: $success_files 个文件"
echo "  失败: $failed_files 个文件"
echo "======================================"

# 根据处理结果设置退出码
if [ "$failed_files" -gt 0 ]; then
  exit 1
fi
exit 0
