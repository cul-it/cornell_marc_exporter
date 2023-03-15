class MARCModel < ASpaceExport::ExportModel
  model_for :marc21

  include JSONModel

@resource_map = {
    [:id_0, :id_1, :id_2, :id_3] => :handle_id,
    :notes => :handle_notes,
    :finding_aid_description_rules => df_handler('fadr', '040', ' ', ' ', 'e'),
    :id_0 => :handle_voyager_id,
    :id => :handle_ref,
    [:finding_aid_status,:ead_id] => :handle_ead_loc
}

# ANW-1416: Maps ISO-3166 country code to MARC country code
  ISO_3166_TO_MARC = {"AE" => "ts", "AF" => "af", "AG" => "aq", "AI" => "ag", "AL" => "aa", "AM" => "ai", "AO" => "ao", "AQ" => "ay", "AR" => "ag", "AS" => "as", "AT" => "au", "AU" => "at", "AW" => "aw", "AX" => "xx", "AZ" => "aj", "BA" => "bn", "BB" => "bb", "BD" => "bg", "BE" => "be", "BF" => "xx", "BG" => "bu", "BH" => "ba", "BI" => "bd", "BJ" => "dm", "BL" => "sc", "BM" => "bm", "BN" => "bx", "BO" => "bo", "BQ" => "xx", "BR" => "bl", "BS" => "bf", "BT" => "bt", "BV" => "bv", "BW" => "bs", "BY" => "bw", "BZ" => "bh", "CA" => "xxc", "CC" => "xb", "CD" => "cg", "CF" => "cx", "CG" => "cf", "CH" => "sz", "CI" => "iv", "CK" => "cw", "CL" => "cl", "CM" => "cm", "CN" => "cc", "CO" => "ck", "CR" => "cr", "CU" => "cu", "CV" => "cv", "CW" => "co", "CX" => "xa", "CY" => "cy", "CZ" => "xr", "DE" => "gw", "DJ" => "ft", "DK" => "dk", "DM" => "dq", "DO" => "dr", "DZ" => "ae", "EC" => "ec", "EE" => "er", "EG" => "ua", "EH" => "ss", "ER" => "ea", "ES" => "sp", "ET" => "et", "FI" => "fi", "FJ" => "fj", "FK" => "fk", "FM" => "fm", "FO" => "fa", "FR" => "fr", "GA" => "go", "GB" => "xxk", "GD" => "gd", "GE" => "gs", "GF" => "gv", "GG" => "gg", "GH" => "gh", "GI" => "gi", "GL" => "gl", "GM" => "gm", "GN" => "gv", "GP" => "gp", "GQ" => "eg", "GR" => "gr", "GS" => "xs", "GT" => "gt", "GU" => "gu", "GW" => "pg", "GY" => "gy", "HK" => "xx", "HM" => "hm", "HN" => "ho", "HR" => "ci", "HT" => "ht", "HU" => "hu", "ID" => "io", "IE" => "ie", "IL" => "is", "IM" => "im", "IN" => "ii", "IO" => "bi", "IQ" => "iq", "IR" => "ir", "IS" => "ic", "IT" => "it", "JE" => "je", "JM" => "jm", "JO" => "jo", "JP" => "ja", "KE" => "ke", "KG" => "kg", "KH" => "cb", "KI" => "gb", "KM" => "cq", "KN" => "xd", "KP" => "kn", "KR" => "ko", "KW" => "ku", "KY" => "cj", "KZ" => "kz", "LA" => "xx", "LB" => "le", "LC" => "xk", "LI" => "lh", "LK" => "ce", "LR" => "lb", "LS" => "lo", "LT" => "li", "LU" => "lu", "LV" => "lv", "LY" => "ly", "MA" => "mr", "MC" => "mc", "MD" => "mv", "ME" => "mo", "MF" => "st", "MG" => "mg", "MH" => "xe", "MK" => "xn", "ML" => "ml", "MM" => "br", "MN" => "mp", "MO" => "xx", "MP" => "nw", "MQ" => "mq", "MR" => "mu", "MS" => "mj", "MT" => "mm", "MU" => "mf", "MV" => "xc", "MW" => "mw", "MX" => "mx", "MY" => "my", "MZ" => "mz", "NA" => "sx", "NC" => "nl", "NE" => "ng", "NF" => "nx", "NG" => "nr", "NI" => "nq", "NL" => "ne", "NO" => "no", "NP" => "np", "NR" => "nu", "NU" => "xh", "NZ" => "nz", "OM" => "mk", "PA" => "pn", "PE" => "pe", "PF" => "fp", "PG" => "pp", "PH" => "ph", "PK" => "pk", "PL" => "pl", "PM" => "xl", "PN" => "pc", "PR" => "pr", "PS" => "xx", "PT" => "po", "PW" => "pw", "PY" => "py", "QA" => "qa", "RE" => "re", "RO" => "rm", "RS" => "rb", "RU" => "ru", "RW" => "rw", "SA" => "su", "SB" => "bp", "SC" => "se", "SD" => "sj", "SE" => "sw", "SG" => "si", "SH" => "xj", "SI" => "xv", "SJ" => "xx", "SK" => "xo", "SL" => "si", "SM" => "sm", "SN" => "sg", "SO" => "so", "SR" => "sr", "SS" => "sd", "ST" => "sf", "SV" => "es", "SX" => "sn", "SY" => "sy", "SZ" => "xx", "TC" => "tc", "TD" => "cd", "TF" => "xx", "TG" => "tg", "TH" => "th", "TJ" => "ta", "TK" => "tl", "TL" => "em", "TM" => "tk", "TN" => "ti", "TO" => "to", "TR" => "tu", "TT" => "tr", "TV" => "tv", "TW" => "xx", "TZ" => "tz", "UA" => "un", "UG" => "ug", "UM" => "xxu", "US" => "xxu", "UY" => "uy", "UZ" => "uz", "VA" => "vc", "VC" => "xm", "VE" => "ve", "VG" => "vb", "VI" => "vi", "VN" => "vm", "VU" => "nn", "WF" => "wf", "WS" => "ws", "YE" => "ye", "YT" => "ot", "ZA" => "sa", "ZM" => "za", "ZW" => "rh"}


def self.from_resource(obj, opts={})
    marc = self.from_archival_object(obj,opts)
    marc.apply_map(obj, @resource_map)
    marc.leader_string = "00000cp$aa2200000 a 4500"
    marc.leader_string[7] = obj.level == 'item' ? 'm' : 'c'

    marc.controlfield_string = assemble_controlfield_string(obj)

    marc
  end


  def self.assemble_controlfield_string(obj)
    date = obj.dates[0] || {}
    string = obj['system_mtime'].scan(/\d{2}/)[1..3].join('')
    string += date['date_type'] == 'single' ? 's' : 'i'
    string += date['begin'] ? date['begin'][0..3] : "    "
    string += date['end'] ? date['end'][0..3] : "    "
    string += "nyu"	

    repo = obj['repository']['_resolved']

#    if repo.has_key?('country') && !repo['country'].empty?
#      string += (ISO_3166_TO_MARC[repo['country']] || "xx")
#    else
#      string += "xx"
#    end

    # If only one Language and Script subrecord its code value should be exported in the MARC 008 field position 35-37; If more than one Language and Script subrecord is recorded, a value of "mul" should be exported in the MARC 008 field position 35-37.
    lang_materials = obj.lang_materials
    languages = lang_materials.map {|l| l['language_and_script']}.compact
    langcode = languages.count == 1 ? languages[0]['language'] : 'mul'    
    (35-(string.length)).times { string += ' ' }	
    string += (langcode || '|||')	
    string += ' d'	
     string	
  end

def handle_ead_loc(finding_aid_status,ead_id)
    if ead_id && !ead_id.empty?
      if finding_aid_status && finding_aid_status == "completed"
      df('856', '4', '2').with_sfs(
                                    ['3', "Finding aid"],
                                    ['u', "http://resolver.library.cornell.edu/cgi-bin/EADresolver?id=" + ead_id]
                                  )
      end
    end
  end

def handle_repo_code(repository,langcode)
  df('040', ' ', ' ').with_sfs(['a', 'NIC'], ['b', 'eng'],['c', 'NIC'])
end

def handle_voyager_id(id_0)
  df('035', ' ', ' ').with_sfs(['a',"(CULAspace)" + id_0])
end

def handle_ref(id)
  df('035', ' ', ' ').with_sfs(['a',"(CULAspaceURI)" + id.to_s])
end

def handle_language(langcode)
  #blocks output of 041
end

end
