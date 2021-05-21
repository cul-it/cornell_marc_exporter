class MARCModel < ASpaceExport::ExportModel
  model_for :marc21

  include JSONModel


@resource_map = {
    [:id_0, :id_1, :id_2, :id_3] => :handle_id,
    :notes => :handle_notes,
    :finding_aid_description_rules => df_handler('fadr', '040', ' ', ' ', 'e'),
    :id_0 => :handle_voyager_id,
    [:id, :repository] => :handle_ref,
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
    (35-(string.length)).times { string += ' ' }	
    string += (obj.language || '|||')	
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

def handle_language(langcode)
  #blocks output of 041
end

def handle_voyager_id(id_0)
  df('035', ' ', ' ').with_sfs(['a',"(CULAspace)" + id_0])
end

def handle_ref(id, repository)
  df('035', ' ', ' ').with_sfs(['a',"(CULAspaceURI)#{repository['ref'].to_s}/resources/#{id.to_s}"])
end

def handle_extents(extents)
  extents.each do |ext|
    e = ext['number']
    t =  "#{I18n.t('enumerations.extent_extent_type.'+ext['extent_type'], :default => ext['extent_type'])}"

    

    df!('300').with_sfs(['a', e], ['f', t])
  end
end


def handle_id(*ids)
  ids.reject!{|i| i.nil? || i.empty?}
  df('099', ' ', '9').with_sfs(['a', ids.join('.')])
 
end

def handle_notes(notes)

  notes.each do |note|
    if note['type'] == 'scopecontent'
      text = ASpaceExport::Utils.extract_note_text(note, @include_unpublished, true) 
      if text.length > 0 
        texts = []
        texts = text.split("\n")
        n = 0
        texts.each do |t|
          n = n+1
          if t.length > 0
            if n == 1
              df!('520', '2', ' ').with_sfs(['a', *Array(t)])
            else
              df!('520', '8', ' ').with_sfs(['a', *Array(t)])
            end
          end
      end
    end

  else

    prefix =  case note['type']
              when 'dimensions'; "Dimensions"
              when 'physdesc'; "Physical Description note"
              when 'materialspec'; "Material Specific Details"
              when 'physloc'; "Location of resource"
              when 'phystech'; "Physical Characteristics / Technical Requirements"
              when 'physfacet'; "Physical Facet"
              when 'processinfo'; "Processing Information"
              when 'separatedmaterial'; "Materials Separated from the Resource"
              else; nil
              end

    marc_args = case note['type']

                when 'arrangement', 'fileplan'
                  ['351', 'a']
                when 'odd', 'dimensions', 'physdesc', 'materialspec', 'physloc', 'phystech', 'physfacet', 'processinfo', 'separatedmaterial'
                  ['500','a']
                when 'accessrestrict'
                  ['506','a']
               
                when 'abstract'
                  ['520', '3', ' ', 'a']
                when 'prefercite'
                  ['524', ' ', ' ', 'a']
                when 'acqinfo'
                  ind1 = note['publish'] ? '1' : '0'
                  ['541', ind1, ' ', 'a']
                when 'relatedmaterial'
                  ['544','d']
                when 'bioghist'
                  ['545','a']
                when 'custodhist'
                  ind1 = note['publish'] ? '1' : '0'
                  ['561', ind1, ' ', 'a']
                when 'appraisal'
                  ind1 = note['publish'] ? '1' : '0'
                  ['583', ind1, ' ', 'a']
                when 'accruals'
                  ['584', 'a']
                when 'altformavail'
                  ['535', '2', ' ', 'a']
                when 'originalsloc'
                  ['535', '1', ' ', 'a']
                when 'userestrict', 'legalstatus'
                  ['540', 'a']
                when 'langmaterial'
                  ['546', 'a']
                when 'otherfindaid'
                  ['555', '0', ' ', 'a']
                else
                  nil
                end

    unless marc_args.nil?
      text = prefix ? "#{prefix}: " : ""
      text += ASpaceExport::Utils.extract_note_text(note, @include_unpublished, true) 

      # only create a tag if there is text to show (e.g., marked published or exporting unpublished)
      if text.length > 0 
        df!(*marc_args[0...-1]).with_sfs([marc_args.last, *Array(text)])
      end
    end
  end
end
end

def handle_notes(notes)

  notes.each do |note|
    if note['type'] == 'scopecontent'
      text = ASpaceExport::Utils.extract_note_text(note, @include_unpublished, true) 
      if text.length > 0 
        texts = []
        texts = text.split("\n")
        n = 0
        texts.each do |t|
          n = n+1
          if t.length > 0
            if n == 1
              df!('520', '2', ' ').with_sfs(['a', *Array(t)])
            else
              df!('520', '8', ' ').with_sfs(['a', *Array(t)])
            end
          end
      end
    end

  else

    prefix =  case note['type']
              when 'dimensions'; "Dimensions"
              when 'physdesc'; "Physical Description note"
              when 'materialspec'; "Material Specific Details"
              when 'physloc'; "Location of resource"
              when 'phystech'; "Physical Characteristics / Technical Requirements"
              when 'physfacet'; "Physical Facet"
              when 'processinfo'; "Processing Information"
              when 'separatedmaterial'; "Materials Separated from the Resource"
              else; nil
              end

    marc_args = case note['type']

                when 'arrangement', 'fileplan'
                  ['351', 'a']
                when 'odd', 'dimensions', 'physdesc', 'materialspec', 'physloc', 'phystech', 'physfacet', 'processinfo', 'separatedmaterial'
                  ['500','a']
                when 'accessrestrict'
                  ['506','a']
               
                when 'abstract'
                  ['520', '3', ' ', 'a']
                when 'prefercite'
                  ['524', ' ', ' ', 'a']
                when 'acqinfo'
                  ind1 = note['publish'] ? '1' : '0'
                  ['541', ind1, ' ', 'a']
                when 'relatedmaterial'
                  ['544','d']
                when 'bioghist'
                  ['545','a']
                when 'custodhist'
                  ind1 = note['publish'] ? '1' : '0'
                  ['561', ind1, ' ', 'a']
                when 'appraisal'
                  ind1 = note['publish'] ? '1' : '0'
                  ['583', ind1, ' ', 'a']
                when 'accruals'
                  ['584', 'a']
                when 'altformavail'
                  ['535', '2', ' ', 'a']
                when 'originalsloc'
                  ['535', '1', ' ', 'a']
                when 'userestrict', 'legalstatus'
                  ['540', 'a']
                when 'langmaterial'
                  ['546', 'a']
                when 'otherfindaid'
                  ['555', '0', ' ', 'a']
                else
                  nil
                end

    unless marc_args.nil?
      text = prefix ? "#{prefix}: " : ""
      text += ASpaceExport::Utils.extract_note_text(note, @include_unpublished, true) 

      # only create a tag if there is text to show (e.g., marked published or exporting unpublished)
      if text.length > 0 
        df!(*marc_args[0...-1]).with_sfs([marc_args.last, *Array(text)])
      end
    end
  end
end
end


def handle_primary_creator(linked_agents)
  link = linked_agents.find{|a| a['role'] == 'creator'}
  return nil unless link
  return nil unless link["_resolved"]["publish"] || @include_unpublished

  creator = link['_resolved']
  name = creator['display_name']

  ind2 = ' '
  role_info = link['relator'] && link['relator'].length == 3  ? ['4', link['relator']] : ['e', link['relator']]

  case creator['agent_type']

  when 'agent_corporate_entity'
    code = '110'
    ind1 = '2'
    sfs = gather_agent_corporate_subfield_mappings(name, role_info, creator)

  when 'agent_person'
    ind1  = name['name_order'] == 'direct' ? '0' : '1'
    code = '100'
    sfs = gather_agent_person_subfield_mappings(name, role_info, creator)

  when 'agent_family'
    code = '100'
    ind1 = '3'
    sfs = gather_agent_family_subfield_mappings(name, role_info, creator)

  end

  df(code, ind1, ind2).with_sfs(*sfs)
end

# TODO: DRY this up
# this method is very similair to handle_primary_creator and handle_agents
def handle_other_creators(linked_agents)
  creators = linked_agents.select{|a| a['role'] == 'creator'}[1..-1] || []
  creators = creators + linked_agents.select{|a| a['role'] == 'source'}

  creators.each do |link|
    next unless link["_resolved"]["publish"] || @include_unpublished

    creator = link['_resolved']
    name = creator['display_name']
    relator = link['relator']
    terms = link['terms']
    role = link['role']

    if role == 'source'
      relator_sf =  ['e', 'former owner']
    else
      relator_sf = ['e', relator]
    end

    ind2 = ' '

    case creator['agent_type']

    when 'agent_corporate_entity'
      code = '710'
      ind1 = '2'
      sfs = gather_agent_corporate_subfield_mappings(name, relator_sf, creator)
   
    when 'agent_person'
      ind1  = name['name_order'] == 'direct' ? '0' : '1'
      code = '700'
      sfs = gather_agent_person_subfield_mappings(name, relator_sf, creator)

    when 'agent_family'
      ind1 = '3'
      code = '700'
      sfs = gather_agent_family_subfield_mappings(name, relator_sf, creator)

    end

    df(code, ind1, ind2).with_sfs(*sfs)
  end
end








end