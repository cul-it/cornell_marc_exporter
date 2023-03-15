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
