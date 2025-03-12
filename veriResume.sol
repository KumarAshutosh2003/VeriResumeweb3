// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ResumeVerification {
    struct Resume {
        string name;
        string email;
        string degree;
        string experience;
        string skills;
        address issuer;
        bool verified;
    }

    mapping(address => Resume) public resumes;
    mapping(address => bool) public authorizedVerifiers;
    
    address public admin;

    event ResumeUploaded(address indexed user, string name, string degree);
    event ResumeVerified(address indexed user, address indexed verifier);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action.");
        _;
    }

    modifier onlyVerifier() {
        require(authorizedVerifiers[msg.sender], "Only verifiers can perform this action.");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function addVerifier(address _verifier) public onlyAdmin {
        authorizedVerifiers[_verifier] = true;
    }

    function uploadResume(
        string memory _name,
        string memory _email,
        string memory _degree,
        string memory _experience,
        string memory _skills
    ) public {
        resumes[msg.sender] = Resume(_name, _email, _degree, _experience, _skills, address(0), false);
        emit ResumeUploaded(msg.sender, _name, _degree);
    }

    function verifyResume(address _user) public onlyVerifier {
        require(bytes(resumes[_user].name).length > 0, "Resume does not exist.");
        require(!resumes[_user].verified, "Resume already verified.");

        resumes[_user].verified = true;
        resumes[_user].issuer = msg.sender;

        emit ResumeVerified(_user, msg.sender);
    }

    function getResume(address _user) public view returns (
        string memory, string memory, string memory, string memory, string memory, address, bool
    ) {
        Resume memory resume = resumes[_user];
        require(bytes(resume.name).length > 0, "Resume does not exist.");
        return (resume.name, resume.email, resume.degree, resume.experience, resume.skills, resume.issuer, resume.verified);
    }
}
