class Job
  include ActiveModel::Model
  attr_accessor :id, :location, :description

  # Cities to include in results
  CITIES = ["Boston", "San Francisco", "Los Angeles", "Denver", "Boulder", "Chicago", "New York"]

  # Languages
  LANGUAGES = ["Objective-C", "Scala", "Swift", "Shell", "TypeScript", "C", "Go", "C#", "CSS", "C++", "PHP", "Ruby",
               "Java", "Python", "JavaScript", "Javascript", "Node.js", "MySQL", "PostgresSQL", "Jenkins", "Azure",
               "MongoDB", "SQL", "Linux", "Elixir", "Elm", "Next.js", "React", "Flux", "Redux", "Express", "HTML"]

  def initialize(params = {})
    @id = params["id"]
    @location = params["location"]
    @description = params["description"]
  end


  def extract_description_text # Remove anchor tags, extract text, remove whitespace, remove blank entries
    doc = Nokogiri::HTML(description)
    doc.search('.//a').remove # Remove Links
    doc.search('//text()').map{|t| t.text.strip}.reject(&:blank?)
  end

  def skills # {"Ruby"=>1, "MySQL"=>1, "Node.js"=>1}
    skill_hashes = []
    skills_hash = {}
    extract_description_text.each do |text|
      skill_hashes << scan_for_skills(text)
    end
    skill_hashes.each do |skill_hash|
      skills_hash.merge!(skill_hash){ |_skill, year_req_1, year_req_2| year_req_1 > year_req_2 ? year_req_1 : year_req_2 } # Keep highest requirement
    end
    skills_hash
  end

  def skills_summary
    skills_hash = skills
    skills_summary_hash = {}
    skills_hash.each do |skill, years_required|
      skills_summary_hash[skill] ||= {"0-2" => 0, "3-5" => 0, "5+" => 0}
      case years_required
        when 0..2
          skills_summary_hash[skill]["0-2"] += 1
        when 3..5
          skills_summary_hash[skill]["3-5"] += 1
        else
          skills_summary_hash[skill]["5+"] += 1
      end
    end
    skills_summary_hash
  end

  def cities_summary
    cities_hash = {}
    job_skills_summary = skills_summary
    cities.each do |city|
      cities_hash[city] = {"total_jobs" => 1}.merge(job_skills_summary)
    end
    cities_hash
  end

  def cities
    if location.nil?
      []
    else
      Job::CITIES.select{|city| location.include?(city)}
    end
  end

  def scan_for_skills(text)
    specified_skills_hash = scan_for_specific_skill_requirements(text)
    specified_skills_list_hash =scan_for_specific_skill_requirement_list(text)
    general_skills_hash = scan_for_general_skills(text)

    general_skills_hash.merge(specified_skills_list_hash).merge(specified_skills_hash) # Merge skill hashes using the most specific requirement if skill is duplicated
  end

  def scan_for_specific_skill_requirements(text) # Search for # year(s) ... Skill => [["#", "Skill"]]
    skills_hash = {}
    scan_result = text.scan(/([\d]+)[\s+]*[\+]*\s+[y|Y]ears*[\w\-\s]+?([A-Z][\w+#]*\.*[\w+#]*)[,]*/)
    unless scan_result.empty?
      scan_result.each do |years, skill|
        skills_hash[skill] = years.to_i
      end
    end
    skills_hash
  end

  def scan_for_specific_skill_requirement_list(text) # Search for # year(s) ... Skill, test, Skill2 => [["#", "Skill, test, Skill2"]]
    skills = []
    skills_hash = {}
    split_text = text.split(". ") # Split on ". " to split lines of text
    split_text.each do |st|
      scan_result = st.scan(/([\d]+)+[\+]*\s+[y|Y]ears*.+?([A-Z][\w +#,\.()\/]*\.*[\w+#,()\/]+)/) # Search for # year(s) ... Skill, test, Skill2 => [["#", "Skill, test, Skill2"]]
      unless scan_result.empty?
        scan_result.each do |years, skill_list|
          skills << scan_for_general_skills(skill_list, years.to_i)
        end
      end
    end
    skills.each do |skill_hash|
      skills_hash.merge!(skill_hash){ |_skill, year_req_1, year_req_2| year_req_1 > year_req_2 ? year_req_1 : year_req_2 } # Keep highest requirement
    end
    skills_hash
  end

  def scan_for_general_skills(text, year_value = 0, whitelist = LANGUAGES) # Search for capital words, assume 0-2 years for these
    skills_hash = {}
    scan_result = text.scan(/([A-Z][\d\w#+]*\.*[\d\w#+]*)/).flatten
    unless whitelist.nil?
      scan_result = scan_result & whitelist
    end
    scan_result.each do |skill|
      skills_hash[skill] = year_value
    end
    skills_hash
  end
end