require 'test_helper'

class JobTest < ActiveSupport::TestCase
  test 'Extract Text' do
    job = Job.new({"description" => sample_description})
    assert job.extract_description_text == expected_extracted_text
  end

  test 'Cities - Single' do
    job = Job.new({"location" => "New York"})
    assert job.cities == ["New York"]
  end

  test 'Cities - Multiple' do
    job = Job.new({"location" => "New York, San Francisco, Las Vegas"})
    assert job.cities.length == 2
    assert job.cities.include?("New York")
    assert job.cities.include?("San Francisco")
  end

  test 'Cities - Rejected' do
    job = Job.new({"location" => "Las Vegas"})
    assert job.cities == []
  end

  test 'Scan for specific skills requirement' do
    text = "2 years Ruby, 1 year C++, 3 Years C#"
    job = Job.new
    assert job.scan_for_specific_skill_requirements(text) == {"Ruby"=>2, "C++"=>1, "C#"=>3}
  end

  test 'Scan for specific skills requirement list' do
    text = "2 years Ruby, Node.js, not, not this, C#. C++, Java. 5 years MySQL"
    job = Job.new
    assert job.scan_for_specific_skill_requirement_list(text) == {"Ruby"=>2, "Node.js"=>2, "C#"=>2, "MySQL"=>5}
  end

  test 'Scan for specific skills requirement list - duplicates' do
    text = "2 years Ruby, Node.js, not, not this, C#. C++, Java. 5 years MySQL, Java, Node.js."
    job = Job.new
    assert job.scan_for_specific_skill_requirement_list(text) == {"Ruby"=>2, "Node.js"=>5, "C#"=>2, "MySQL"=> 5, "Java"=>5}
  end

  test 'Scan for general skills - no whitelist' do
    text = "This is a test string Ruby on Rails, MySQL, Not, Node.js."
    job = Job.new
    assert job.scan_for_general_skills(text, 0, nil) == {"This"=>0, "Ruby"=>0, "Rails"=>0, "MySQL"=>0, "Not"=>0, "Node.js"=>0}
  end

  test 'Scan for general skills - whitelist, year value' do
    text = "This is a test string Ruby, MySQL, Not, Node.js"
    job = Job.new
    assert job.scan_for_general_skills(text, 1, ["Ruby", "MySQL", "Node.js"]) == {"Ruby"=>1, "MySQL"=>1, "Node.js"=>1}
  end

  test 'Skills' do
    job = Job.new({"description" => sample_description})
    assert job.skills == {"Python"=>0, "Javascript"=>0, "Swift"=>0, "React"=>0}
  end

  test 'Skills Summary' do
    job = Job.new({"description" => sample_description})
    assert job.skills_summary == {"Python"=>{"0-2"=>1, "3-5"=>0, "5+"=>0}, "Javascript"=>{"0-2"=>1, "3-5"=>0, "5+"=>0}, "Swift"=>{"0-2"=>1, "3-5"=>0, "5+"=>0}, "React"=>{"0-2"=>1, "3-5"=>0, "5+"=>0}}
  end

  test 'Cities Summary' do
    job = Job.new({"location" => "New York, Boulder, Las Vegas", "description" => sample_description})
    assert job.cities_summary == {"Boulder"=>{"total_jobs"=>1, "Python"=>{"0-2"=>1, "3-5"=>0, "5+"=>0}, "Javascript"=>{"0-2"=>1, "3-5"=>0, "5+"=>0}, "Swift"=>{"0-2"=>1, "3-5"=>0, "5+"=>0}, "React"=>{"0-2"=>1, "3-5"=>0, "5+"=>0}}, "New York"=>{"total_jobs"=>1, "Python"=>{"0-2"=>1, "3-5"=>0, "5+"=>0}, "Javascript"=>{"0-2"=>1, "3-5"=>0, "5+"=>0}, "Swift"=>{"0-2"=>1, "3-5"=>0, "5+"=>0}, "React"=>{"0-2"=>1, "3-5"=>0, "5+"=>0}}}
  end


  def sample_description
    "<p>Compensation: $70,000 - $120,000 &amp; Equity</p>\n\n<p>Website: <a href=\"https://www.leaf.ag\">https://www.leaf.ag/</a></p>\n\n<p>Agrarian Labs is an early stage AgTech startup. Our product, Leaf, is an automated business intelligence app for farmers. Leaf launched commercially in Spring 2017 and we're ramping up for significant growth in 2018.</p>\n\n<h2>Who You'll Work With and What We're Here For</h2>\n\n<p>Our team is on a journey to build the best company in AgTech. We're here to help make farmers more sustainable, more profitable, and more successful. Today we're a diverse, multidisciplinary team valuing a wide breadth of experience:</p>\n\n<ul>\n<li><p>Some of us have graduate computer science degrees, some are self-taught creatives.</p></li>\n<li><p>We grew from educations as wide ranging as Stanford, EPITECH and boot camps.</p></li>\n<li><p>We've learned from amazing companies including BCG, Deloitte, and EPIC Health Systems, small farms, agribusinesses, and numerous tech startups.</p></li>\n</ul><p>As a small team we have extraordinary ownership within the company. Our culture grows from within: its not a gimmick. We value strong combinations of self-awareness, talent, and pragmatism.</p>\n\n<ul>\n<li>Self-awareness leads to an atmosphere of collaboration and idea meritocracy.</li>\n<li>Talent enables us to tackle challenging problems, find passion for learning, and build mutual trust.</li>\n<li>Pragmatism supports mature choices, prioritization, and transparency when overcoming challenges.</li>\n</ul><h2>Responsibilities</h2>\n\n<ul>\n<li>Build and evolve 3rd party integrations with companies like John Deere to mine data spanning imagery, crop nutrients, and machine statistics.</li>\n<li>Develop data pipelines and proprietary algorithms (including Machine Learning) that transform raw data into information and knowledge that farmers can take action from.</li>\n<li>Work with and on our microservices deployment, cloud infrastructure, and development tooling.</li>\n</ul><h2>Technologies We Use Collectively</h2>\n\n<p>Golang, Python, Javascript, Swift\nAWS, Docker, React\nPostgres, NSQ, Postgis, Redis, Elasticsearch</p>\n\n<h2>Must Haves</h2>\n\n<ul>\n<li>3+ \"believable, successful\" experiences in software development. This includes demonstrable success with previous companies, products, education, etc.</li>\n<li>Experience overcoming complex software problems. Examples might include implementing saga patterns or distributed transactions, designing and deploying ML models, or creating supervision structures to handle unstable integrations.</li>\n<li>Knowledge of how computing systems function and operate, including data stores, concurrency models, compilation, testing, and static analysis.</li>\n</ul><h2>Benefits &amp; Perks</h2>\n\n<ul>\n<li>Full benefits including health, dental and vision insurance</li>\n<li>Flexible work structure (hours, locale, etc)</li>\n<li>Take-care of yourself to take care of the company perspective for vacation, time off, etc.</li>\n<li>Team bonding events</li>\n</ul>"
  end

  def expected_extracted_text
    ["Compensation: $70,000 - $120,000 & Equity", "Website:", "Agrarian Labs is an early stage AgTech startup. Our product, Leaf, is an automated business intelligence app for farmers. Leaf launched commercially in Spring 2017 and we're ramping up for significant growth in 2018.", "Who You'll Work With and What We're Here For", "Our team is on a journey to build the best company in AgTech. We're here to help make farmers more sustainable, more profitable, and more successful. Today we're a diverse, multidisciplinary team valuing a wide breadth of experience:", "Some of us have graduate computer science degrees, some are self-taught creatives.", "We grew from educations as wide ranging as Stanford, EPITECH and boot camps.", "We've learned from amazing companies including BCG, Deloitte, and EPIC Health Systems, small farms, agribusinesses, and numerous tech startups.", "As a small team we have extraordinary ownership within the company. Our culture grows from within: its not a gimmick. We value strong combinations of self-awareness, talent, and pragmatism.", "Self-awareness leads to an atmosphere of collaboration and idea meritocracy.", "Talent enables us to tackle challenging problems, find passion for learning, and build mutual trust.", "Pragmatism supports mature choices, prioritization, and transparency when overcoming challenges.", "Responsibilities", "Build and evolve 3rd party integrations with companies like John Deere to mine data spanning imagery, crop nutrients, and machine statistics.", "Develop data pipelines and proprietary algorithms (including Machine Learning) that transform raw data into information and knowledge that farmers can take action from.", "Work with and on our microservices deployment, cloud infrastructure, and development tooling.", "Technologies We Use Collectively", "Golang, Python, Javascript, Swift\nAWS, Docker, React\nPostgres, NSQ, Postgis, Redis, Elasticsearch", "Must Haves", "3+ \"believable, successful\" experiences in software development. This includes demonstrable success with previous companies, products, education, etc.", "Experience overcoming complex software problems. Examples might include implementing saga patterns or distributed transactions, designing and deploying ML models, or creating supervision structures to handle unstable integrations.", "Knowledge of how computing systems function and operate, including data stores, concurrency models, compilation, testing, and static analysis.", "Benefits & Perks", "Full benefits including health, dental and vision insurance", "Flexible work structure (hours, locale, etc)", "Take-care of yourself to take care of the company perspective for vacation, time off, etc.", "Team bonding events"]
  end

end